require "test_helper"
require "webmock/minitest"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  teardown do
    WebMock.allow_net_connect!
  end

  # ---------------------------------------------------------------------------
  # index
  # ---------------------------------------------------------------------------

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should sort index by author ascending" do
    get books_url, params: { sort: "author", direction: "asc" }
    assert_response :success
  end

  test "should sort index by rating descending" do
    get books_url, params: { sort: "rating", direction: "desc" }
    assert_response :success
  end

  test "should sort index by series ascending" do
    get books_url, params: { sort: "series", direction: "asc" }
    assert_response :success
  end

  test "should sort index by series descending" do
    get books_url, params: { sort: "series", direction: "desc" }
    assert_response :success
  end

  test "should fall back to default sort for an unknown column" do
    # Ensures SQL injection via sort param does not raise or corrupt data
    get books_url, params: { sort: "'; DROP TABLE books; --", direction: "asc" }
    assert_response :success
    assert Book.count > 0, "books table must still exist after bad sort param"
  end

  test "should fall back to default direction for an invalid value" do
    get books_url, params: { sort: "title", direction: "INVALID; --" }
    assert_response :success
  end

  # ---------------------------------------------------------------------------
  # new / create
  # ---------------------------------------------------------------------------

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book and persist to database" do
    assert_difference("Book.count") do
      post books_url, params: { book: { title: "Test Book", status: "want_to_read", book_type: "physical_book" } }
    end
    assert_redirected_to book_url(Book.last)
    assert_equal "Test Book", Book.last.title
    assert_equal "want_to_read", Book.last.status
  end

  test "should not create book with blank title" do
    assert_no_difference("Book.count") do
      post books_url, params: { book: { title: "", status: "want_to_read", book_type: "physical_book" } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # show
  # ---------------------------------------------------------------------------

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  # ---------------------------------------------------------------------------
  # edit / update
  # ---------------------------------------------------------------------------

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book and persist changes to database" do
    patch book_url(@book), params: { book: { title: "Updated Title", status: "read", book_type: "ebook" } }
    assert_redirected_to book_url(@book)
    @book.reload
    assert_equal "Updated Title", @book.title
    assert_equal "read", @book.status
    assert_equal "ebook", @book.book_type
  end

  test "should update book via turbo_stream and respond with stream replacements" do
    patch book_url(@book), params: { book: { title: "Turbo Updated Title", status: "read", book_type: "ebook" } }, as: :turbo_stream
    assert_response :success
    assert_includes response.body, %(target="read_section")
    assert_includes response.body, %(target="book_modal")
    assert_equal "Turbo Updated Title", @book.reload.title
  end

  test "should refresh both old and new status sections when status changes via turbo_stream" do
    @book.update!(status: "want_to_read")
    patch book_url(@book), params: { book: { title: @book.title, status: "read", book_type: @book.book_type } }, as: :turbo_stream
    assert_response :success
    assert_includes response.body, %(target="read_section"), "new status section must be refreshed"
    assert_includes response.body, %(target="want_to_read_section"), "old status section must be refreshed"
    assert_equal "read", @book.reload.status
  end

  test "should return unprocessable_entity via turbo_stream when update fails" do
    patch book_url(@book), params: { book: { title: "" } }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_includes response.body, %(target="book_modal")
  end

  test "should not update book with blank title" do
    original_title = @book.title
    patch book_url(@book), params: { book: { title: "" } }
    assert_response :unprocessable_entity
    assert_equal original_title, @book.reload.title
  end

  # ---------------------------------------------------------------------------
  # destroy
  # ---------------------------------------------------------------------------

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  # ---------------------------------------------------------------------------
  # restore
  # ---------------------------------------------------------------------------

  test "should restore the last deleted book" do
    book_to_delete = books(:two)
    expected_title  = book_to_delete.title
    expected_status = book_to_delete.status

    delete book_url(book_to_delete)
    assert_equal 0, Book.where(title: expected_title).count

    assert_difference("Book.count", +1) do
      post restore_book_url
    end
    restored = Book.find_by(title: expected_title)
    assert_not_nil restored
    assert_equal expected_status, restored.status
  end

  test "should return unprocessable_entity via turbo_stream when nothing to restore" do
    post restore_book_url, as: :turbo_stream
    assert_response :unprocessable_entity
  end

  test "should redirect with alert via html when nothing to restore" do
    post restore_book_url
    assert_redirected_to books_url
    assert_equal "No book to restore.", flash[:alert]
  end

  # ---------------------------------------------------------------------------
  # update_status
  # ---------------------------------------------------------------------------

  test "should update book status and respond with turbo_stream" do
    @book.update!(status: :want_to_read)
    patch update_status_book_url(@book), params: { status: "currently_reading" },
                                          as: :turbo_stream
    assert_response :success
    assert_equal "currently_reading", @book.reload.status
  end

  test "should return 422 for invalid status value via turbo_stream" do
    patch update_status_book_url(@book), params: { status: "invalid_status" }, as: :turbo_stream
    assert_response :unprocessable_entity
  end

  test "should return 422 for invalid status value via JSON" do
    patch update_status_book_url(@book), params: { status: "invalid_status" }, as: :json
    assert_response :unprocessable_entity
    assert_equal "Invalid status value", JSON.parse(response.body)["error"]
  end

  test "should update book status and respond with JSON" do
    @book.update!(status: :want_to_read)
    patch update_status_book_url(@book), params: { status: "read" }, as: :json
    assert_response :success
    assert_equal "read", @book.reload.status
  end

  test "should transition through all valid statuses" do
    @book.update!(status: :want_to_read)
    patch update_status_book_url(@book), params: { status: "currently_reading" }, as: :json
    assert_equal "currently_reading", @book.reload.status

    patch update_status_book_url(@book), params: { status: "read" }, as: :json
    assert_equal "read", @book.reload.status
  end

  test "should return 404 for non-existent book in update_status" do
    patch update_status_book_url(id: 999999), params: { status: "read" }, as: :turbo_stream
    assert_response :not_found
  end

  test "should return 404 for non-existent book in update_status via JSON" do
    patch update_status_book_url(id: 999999), params: { status: "read" }, as: :json
    assert_response :not_found
  end

  # ---------------------------------------------------------------------------
  # search
  # ---------------------------------------------------------------------------

  test "should get search with no query" do
    get search_books_url
    assert_response :success
  end

  test "should return results from OpenLibrary search" do
    stub_openlibrary_search([
      { "open_library_id" => "OL999W", "title" => "A New Book",
        "authors" => [ "Some Author" ], "publication_year" => 2024 }
    ])

    get search_books_url, params: { query: "A New Book" }
    assert_response :success
  end

  test "should exclude books already in the collection from search results" do
    # Return two results: one already owned, one not
    stub_openlibrary_search([
      { "open_library_id" => @book.open_library_id, "title" => @book.title,
        "authors" => [ @book.author ] },
      { "open_library_id" => "OL_BRAND_NEW_W", "title" => "Brand New Book",
        "authors" => [ "New Author" ] }
    ])

    get search_books_url, params: { query: "test" }
    assert_response :success
    # Owned book should be filtered; only the unowned one should appear in assigns
    visible_ids = assigns(:search_results).map { |r| r["open_library_id"] }
    assert_not_includes visible_ids, @book.open_library_id
    assert_includes visible_ids, "OL_BRAND_NEW_W"
  end

  test "should handle search API failure gracefully" do
    stub_request(:get, /openlibrary\.org\/search\.json/)
      .to_return(status: 500, body: "error")

    get search_books_url, params: { query: "test" }
    assert_response :success
    assert_empty assigns(:search_results)
  end

  test "should handle search network error gracefully" do
    stub_request(:get, /openlibrary\.org\/search\.json/)
      .to_raise(HTTParty::Error.new("connection failed"))

    get search_books_url, params: { query: "test" }
    assert_response :success
    assert_empty assigns(:search_results)
  end

  test "should sort search results by title" do
    stub_openlibrary_search([
      { "open_library_id" => "OL1W", "title" => "Zebra Book", "authors" => [], "publication_year" => 2020 },
      { "open_library_id" => "OL2W", "title" => "Apple Book", "authors" => [], "publication_year" => 2021 }
    ])

    get search_books_url, params: { query: "book", search_sort: "title", search_direction: "asc" }
    assert_response :success
    titles = assigns(:search_results).map { |r| r["title"] }
    assert_equal titles.sort, titles
  end

  # ---------------------------------------------------------------------------
  # add_from_search
  # ---------------------------------------------------------------------------

  test "should add book from search with want_to_read status" do
    assert_difference("Book.count") do
      post add_from_search_books_url, params: {
        title: "Search Result Book",
        authors: "Search Author",
        publication_year: 2024,
        open_library_id: "OL_FROM_SEARCH_W",
        status: "want_to_read"
      }, as: :turbo_stream
    end
    assert_response :success

    added = Book.find_by(open_library_id: "OL_FROM_SEARCH_W")
    assert_not_nil added
    assert_equal "Search Result Book", added.title
    assert_equal "Search Author", added.author
    assert_equal "want_to_read", added.status
    assert_equal "physical_book", added.book_type
  end

  test "should add book from search with currently_reading status" do
    assert_difference("Book.count") do
      post add_from_search_books_url, params: {
        title: "Currently Reading Book",
        authors: "Author",
        open_library_id: "OL_READING_W",
        status: "currently_reading"
      }, as: :turbo_stream
    end
    assert_equal "currently_reading", Book.find_by(open_library_id: "OL_READING_W").status
  end

  test "should add book from search with read status" do
    assert_difference("Book.count") do
      post add_from_search_books_url, params: {
        title: "Already Read Book",
        authors: "Author",
        open_library_id: "OL_READ_W",
        status: "read"
      }, as: :turbo_stream
    end
    assert_equal "read", Book.find_by(open_library_id: "OL_READ_W").status
  end

  test "should not add book from search when title is missing" do
    assert_no_difference("Book.count") do
      post add_from_search_books_url, params: {
        title: "",
        status: "want_to_read"
      }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  test "should return 422 for invalid status in add_from_search" do
    assert_no_difference("Book.count") do
      post add_from_search_books_url, params: {
        title: "Some Book",
        open_library_id: "OL999W",
        status: "not_a_real_status"
      }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  private

  # Stubs the upstream OpenLibrary API with results expressed in the
  # already-transformed shape (open_library_id, title, authors, publication_year).
  # Converts them back to the raw docs format that OpenLibrarySearchService expects.
  def stub_openlibrary_search(results)
    docs = results.map do |r|
      {
        key: "/works/#{r['open_library_id']}",
        title: r["title"],
        author_name: Array(r["authors"]),
        first_publish_year: r["publication_year"]
      }.compact
    end
    stub_request(:get, /openlibrary\.org\/search\.json/)
      .to_return(
        status: 200,
        body: { docs: docs }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
