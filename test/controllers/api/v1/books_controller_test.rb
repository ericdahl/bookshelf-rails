require "test_helper"

class Api::V1::BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one) # The Fellowship of the Ring
    @minimal_book = books(:minimal_book)
    @complete_book = books(:complete_book)
    @invalid_rating_book = books(:invalid_rating_book)

    @valid_attributes = {
      title: "Test Book",
      author: "Test Author",
      isbn_10: "1234567891",
      isbn_13: "9781234567891",
      publication_year: 2024,
      publisher: "Test Publisher",
      page_count: 300,
      description: "Test Description",
      cover_image_url: "https://example.com/cover.jpg",
      open_library_id: "OL123456W",
      status: "want_to_read",
      book_type: "physical_book"
    }
    @invalid_attributes = {
      title: "",
      status: "want_to_read"
    }
  end

  test "should get index" do
    get api_v1_books_url, as: :json
    assert_response :success
    response_books = JSON.parse(response.body)
    assert_not_empty response_books
  end

  test "should create book" do
    assert_difference("Book.count") do
      post api_v1_books_url, params: { book: @valid_attributes }, as: :json
    end
    assert_response :created
    assert_equal @valid_attributes[:title], Book.last.title
  end

  test "should not create book with invalid attributes" do
    assert_no_difference("Book.count") do
      post api_v1_books_url, params: { book: @invalid_attributes }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should show book" do
    get api_v1_book_url(@book), as: :json
    assert_response :success
    response_book = JSON.parse(response.body)
    assert_equal @book.id, response_book["id"]
    assert_equal @book.title, response_book["title"]
    assert_equal @book.author, response_book["author"]
  end

  test "should return 404 for non-existent book" do
    get api_v1_book_url(id: 999999), as: :json
    assert_response :not_found
    assert_equal "Book not found", JSON.parse(response.body)["error"]
  end

  test "should update book" do
    patch api_v1_book_url(@book), params: { book: { title: "Updated Title" } }, as: :json
    assert_response :success
    @book.reload
    assert_equal "Updated Title", @book.title
  end

  test "should not update book with invalid attributes" do
    patch api_v1_book_url(@book), params: { book: @invalid_attributes }, as: :json
    assert_response :unprocessable_entity
    @book.reload
    assert_not_equal @invalid_attributes[:title], @book.title
  end

  test "should return 404 when updating non-existent book" do
    patch api_v1_book_url(id: 999999), params: { book: @valid_attributes }, as: :json
    assert_response :not_found
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete api_v1_book_url(@book), as: :json
    end
    assert_response :no_content
  end

  test "should return 404 when destroying non-existent book" do
    delete api_v1_book_url(id: 999999), as: :json
    assert_response :not_found
  end

  # Edge cases and additional validations
  test "should handle book with minimal required fields" do
    minimal_attributes = {
      title: "Minimal Book",
      status: "want_to_read",
      book_type: "physical_book"
    }
    assert_difference("Book.count") do
      post api_v1_books_url, params: { book: minimal_attributes }, as: :json
    end
    assert_response :created
  end

  test "should validate rating range" do
    invalid_rating_attributes = @valid_attributes.merge(rating: 11) # Rating should be 1-10
    assert_no_difference("Book.count") do
      post api_v1_books_url, params: { book: invalid_rating_attributes }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should handle book with series" do
    series = series(:lotr)
    book_with_series = @valid_attributes.merge(
      series_id: series.id,
      isbn_10: "1234567892",
      isbn_13: "9781234567892"
    )
    assert_difference("Book.count") do
      post api_v1_books_url, params: { book: book_with_series }, as: :json
    end
    assert_response :created
    assert_equal series.id, Book.last.series_id
  end

  test "should handle book with all date fields" do
    book_with_dates = @valid_attributes.merge(
      date_added: Date.today,
      date_started: Date.today,
      date_finished: Date.today,
      isbn_10: "1234567893",
      isbn_13: "9781234567893"
    )
    assert_difference("Book.count") do
      post api_v1_books_url, params: { book: book_with_dates }, as: :json
    end
    assert_response :created
  end

  test "should handle book with all optional fields" do
    complete_attributes = @valid_attributes.merge(
      isbn_10: "1234567894",
      isbn_13: "9781234567894"
    )
    assert_difference("Book.count") do
      post api_v1_books_url, params: { book: complete_attributes }, as: :json
    end
    assert_response :created
    response_book = JSON.parse(response.body)
    assert_equal complete_attributes[:title], response_book["title"]
    assert_equal complete_attributes[:author], response_book["author"]
    assert_nil response_book["rating"]
  end

  test "should handle book with invalid rating from fixture" do
    assert_no_difference("Book.count") do
      post api_v1_books_url, params: { book: @invalid_rating_book.attributes }, as: :json
    end
    assert_response :unprocessable_entity
  end
end
