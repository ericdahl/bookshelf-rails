require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @book = books(:one)
  end

  # ---------------------------------------------------------------------------
  # Basic validity
  # ---------------------------------------------------------------------------

  test "should be valid with all required fields" do
    assert @book.valid?
  end

  # ---------------------------------------------------------------------------
  # title validation
  # ---------------------------------------------------------------------------

  test "title should be present" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "title blank string should be invalid" do
    @book.title = "   "
    assert_not @book.valid?
  end

  # ---------------------------------------------------------------------------
  # status validation
  # ---------------------------------------------------------------------------

  test "status should be present" do
    @book.status = nil
    assert_not @book.valid?
    assert_includes @book.errors[:status], "can't be blank"
  end

  test "status should be one of the allowed enum values" do
    assert_raises(ArgumentError) { @book.status = "invalid_status" }
  end

  test "all valid statuses are accepted" do
    %w[want_to_read currently_reading read].each do |status|
      @book.status = status
      assert @book.valid?, "Expected status '#{status}' to be valid"
    end
  end

  # ---------------------------------------------------------------------------
  # book_type validation
  # ---------------------------------------------------------------------------

  test "book_type should be one of the allowed enum values" do
    assert_raises(ArgumentError) { @book.book_type = "invalid_type" }
  end

  test "all valid book_types are accepted" do
    %w[physical_book ebook audiobook].each do |type|
      @book.book_type = type
      assert @book.valid?, "Expected book_type '#{type}' to be valid"
    end
  end

  # ---------------------------------------------------------------------------
  # rating validation
  # ---------------------------------------------------------------------------

  test "rating 0 should be invalid" do
    @book.rating = 0
    assert_not @book.valid?
    assert_includes @book.errors[:rating], "must be greater than or equal to 1"
  end

  test "rating 11 should be invalid" do
    @book.rating = 11
    assert_not @book.valid?
    assert_includes @book.errors[:rating], "must be less than or equal to 10"
  end

  test "rating at lower boundary (1) should be valid" do
    @book.rating = 1
    assert @book.valid?
  end

  test "rating at upper boundary (10) should be valid" do
    @book.rating = 10
    assert @book.valid?
  end

  test "rating of 5 should be valid" do
    @book.rating = 5
    assert @book.valid?
  end

  test "rating can be nil" do
    @book.rating = nil
    assert @book.valid?
  end

  test "rating must be an integer" do
    @book.rating = 5.5
    assert_not @book.valid?
    assert_includes @book.errors[:rating], "must be an integer"
  end

  # ---------------------------------------------------------------------------
  # series association
  # ---------------------------------------------------------------------------

  test "series association is optional" do
    @book.series = nil
    assert @book.valid?
  end

  test "book belongs to an existing series" do
    assert_equal series(:lotr), @book.series
  end

  # ---------------------------------------------------------------------------
  # ISBN fields
  # ---------------------------------------------------------------------------

  test "can have valid ISBNs" do
    @book.isbn_10 = "0306406152"
    @book.isbn_13 = "9780306406157"
    assert @book.valid?
  end

  test "can have nil ISBNs" do
    @book.isbn_10 = nil
    @book.isbn_13 = nil
    assert @book.valid?
  end

  # NOTE: isbn_10 and isbn_13 uniqueness validations are commented out on main.
  # The following tests cover the desired behavior and will pass once
  # PR #120 (fix/db-constraints-and-indexes) is merged and the validations
  # are enabled in the model.
  #
  # test "isbn_13 should be unique" do
  #   duplicate = Book.new(
  #     title: "Duplicate ISBN Book",
  #     status: :want_to_read,
  #     book_type: :physical_book,
  #     isbn_13: @book.isbn_13
  #   )
  #   assert_not duplicate.valid?
  #   assert_includes duplicate.errors[:isbn_13], "has already been taken"
  # end
  #
  # test "isbn_10 should be unique" do
  #   duplicate = Book.new(
  #     title: "Duplicate ISBN Book",
  #     status: :want_to_read,
  #     book_type: :physical_book,
  #     isbn_10: @book.isbn_10
  #   )
  #   assert_not duplicate.valid?
  #   assert_includes duplicate.errors[:isbn_10], "has already been taken"
  # end

  # ---------------------------------------------------------------------------
  # Fixtures sanity check (documents what data is available in tests)
  # ---------------------------------------------------------------------------

  test "fixture books cover all three statuses" do
    assert Book.find_by(status: "want_to_read"),    "expected a want_to_read fixture"
    assert Book.find_by(status: "currently_reading"), "expected a currently_reading fixture"
    assert Book.find_by(status: "read"),             "expected a read fixture"
  end

  test "fixture books cover all three book_types" do
    assert Book.find_by(book_type: "physical_book"), "expected a physical_book fixture"
    assert Book.find_by(book_type: "ebook"),         "expected an ebook fixture"
    assert Book.find_by(book_type: "audiobook"),     "expected an audiobook fixture"
  end
end
