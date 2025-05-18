require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup do
    @book = books(:one)
  end

  test "visiting the index" do
    visit books_path
    assert_selector "h1", text: "Books"
  end

  test "should create book" do
    visit books_path
    click_on "New book"

    fill_in "Title", with: @book.title
    fill_in "Author", with: @book.author
    fill_in "Isbn 13", with: "999999999999#{Time.current.to_i}"
    select @book.status.humanize, from: "Status"
    select @book.book_type.humanize, from: "Book type"
    click_on "Create Book"

    assert_text "Book was successfully created"
    click_on "Back"
  end

  test "should update Book" do
    visit book_path(@book)
    click_on "Edit this book", match: :first

    fill_in "Title", with: @book.title
    fill_in "Author", with: @book.author
    fill_in "Isbn 13", with: @book.isbn_13
    select @book.status.humanize, from: "Status"
    select @book.book_type.humanize, from: "Book type"
    click_on "Update Book"

    assert_text "Book was successfully updated"
    click_on "Back"
  end

  test "should destroy Book" do
    visit book_path(@book)
    accept_confirm { click_on "Destroy this book", match: :first }

    assert_text "Book was successfully destroyed"
  end
end
