require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup do
    @book = books(:one)
  end

  test "visiting the index" do
    visit books_url
    assert_selector "h1", text: "Books"
  end

  test "should create book" do
    visit books_url
    click_on "New book"

    fill_in "Author", with: @book.author_id
    fill_in "Cover url", with: @book.cover_url
    fill_in "Finished reading at", with: @book.finished_reading_at
    fill_in "Genre", with: @book.genre
    fill_in "Isbn", with: @book.isbn
    fill_in "Media type", with: @book.media_type
    fill_in "Open library", with: @book.open_library_id
    fill_in "Page count", with: @book.page_count
    fill_in "Published date", with: @book.published_date
    fill_in "Series", with: @book.series_id
    fill_in "Started reading at", with: @book.started_reading_at
    fill_in "Status", with: @book.status
    fill_in "Title", with: @book.title
    fill_in "User comments", with: @book.user_comments
    fill_in "User rating", with: @book.user_rating
    click_on "Create Book"

    assert_text "Book was successfully created"
    click_on "Back"
  end

  test "should update Book" do
    visit book_url(@book)
    click_on "Edit this book", match: :first

    fill_in "Author", with: @book.author_id
    fill_in "Cover url", with: @book.cover_url
    fill_in "Finished reading at", with: @book.finished_reading_at.to_s
    fill_in "Genre", with: @book.genre
    fill_in "Isbn", with: @book.isbn
    fill_in "Media type", with: @book.media_type
    fill_in "Open library", with: @book.open_library_id
    fill_in "Page count", with: @book.page_count
    fill_in "Published date", with: @book.published_date
    fill_in "Series", with: @book.series_id
    fill_in "Started reading at", with: @book.started_reading_at.to_s
    fill_in "Status", with: @book.status
    fill_in "Title", with: @book.title
    fill_in "User comments", with: @book.user_comments
    fill_in "User rating", with: @book.user_rating
    click_on "Update Book"

    assert_text "Book was successfully updated"
    click_on "Back"
  end

  test "should destroy Book" do
    visit book_url(@book)
    click_on "Destroy this book", match: :first

    assert_text "Book was successfully destroyed"
  end
end
