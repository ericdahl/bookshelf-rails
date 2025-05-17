require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @book = books(:one)  # Using the fixture data
  end

  test "should be valid" do
    assert @book.valid?
  end

  test "title should be present" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "status should be present" do
    @book.status = nil
    assert_not @book.valid?
    assert_includes @book.errors[:status], "can't be blank"
  end

  test "status should be one of the enum values" do
    assert_raises(ArgumentError) do
      @book.status = "invalid_status"
    end
  end

  test "book_type should be one of the enum values" do
    assert_raises(ArgumentError) do
      @book.book_type = "invalid_type"
    end
  end

  test "rating should be between 1 and 10" do
    @book.rating = 0
    assert_not @book.valid?
    assert_includes @book.errors[:rating], "must be greater than or equal to 1"

    @book.rating = 11
    assert_not @book.valid?
    assert_includes @book.errors[:rating], "must be less than or equal to 10"

    @book.rating = 5
    assert @book.valid?
  end

  test "rating can be nil" do
    @book.rating = nil
    assert @book.valid?
  end

  test "series association is optional" do
    assert @book.valid?
    @book.series = nil
    assert @book.valid?
  end

  test "can have valid ISBNs" do
    @book.isbn_10 = "1234567890"
    @book.isbn_13 = "1234567890123"
    assert @book.valid?
  end

  test "can have nil ISBNs" do
    @book.isbn_10 = nil
    @book.isbn_13 = nil
    assert @book.valid?
  end

  test "can access different fixture books" do
    fellowship = books(:one)
    nineteen_eighty_four = books(:two)
    way_of_kings = books(:the_way_of_kings)

    assert_equal "The Fellowship of the Ring", fellowship.title
    assert_equal "1984", nineteen_eighty_four.title
    assert_equal "The Way of Kings", way_of_kings.title
  end
end
