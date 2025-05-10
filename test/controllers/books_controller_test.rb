require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
  end

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post books_url, params: { book: { author_id: @book.author_id, cover_url: @book.cover_url, finished_reading_at: @book.finished_reading_at, genre: @book.genre, isbn: @book.isbn, media_type: @book.media_type, open_library_id: @book.open_library_id, page_count: @book.page_count, published_date: @book.published_date, series_id: @book.series_id, started_reading_at: @book.started_reading_at, status: @book.status, title: @book.title, user_comments: @book.user_comments, user_rating: @book.user_rating } }
    end

    assert_redirected_to book_url(Book.last)
  end

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { book: { author_id: @book.author_id, cover_url: @book.cover_url, finished_reading_at: @book.finished_reading_at, genre: @book.genre, isbn: @book.isbn, media_type: @book.media_type, open_library_id: @book.open_library_id, page_count: @book.page_count, published_date: @book.published_date, series_id: @book.series_id, started_reading_at: @book.started_reading_at, status: @book.status, title: @book.title, user_comments: @book.user_comments, user_rating: @book.user_rating } }
    assert_redirected_to book_url(@book)
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end
end
