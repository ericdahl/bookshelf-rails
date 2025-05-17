require "test_helper"

class SeriesTest < ActiveSupport::TestCase
  def setup
    @series = Series.new(name: "Test Series", description: "A test series")
  end

  test "should be valid" do
    assert @series.valid?
  end

  test "name should be present" do
    @series.name = nil
    assert_not @series.valid?
    assert_includes @series.errors[:name], "can't be blank"
  end

  test "name should be unique" do
    duplicate_series = @series.dup
    @series.save
    assert_not duplicate_series.valid?
    assert_includes duplicate_series.errors[:name], "has already been taken"
  end

  test "should have many books" do
    assert_respond_to @series, :books
  end

  test "should nullify associated books when destroyed" do
    @series.save
    book = Book.create!(title: "Test Book", series: @series, status: :want_to_read)
    @series.destroy
    assert_nil book.reload.series_id
  end

  test "can be created with valid attributes" do
    assert_difference "Series.count" do
      Series.create!(name: "New Series", description: "A new series")
    end
  end

  test "can be updated" do
    @series.save
    new_name = "Updated Series"
    @series.update(name: new_name)
    assert_equal new_name, @series.reload.name
  end

  test "can be destroyed" do
    @series.save
    assert_difference "Series.count", -1 do
      @series.destroy
    end
  end
end
