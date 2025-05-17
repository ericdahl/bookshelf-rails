require "test_helper"

class SeriesTest < ActiveSupport::TestCase
  def setup
    @series = series(:lotr)
  end

  test "fixtures are loaded correctly" do
    lotr = series(:lotr)
    stormlight = series(:stormlight)

    assert_equal "The Lord of the Rings", lotr.name
    assert_equal "Epic high fantasy by J.R.R. Tolkien.", lotr.description
    
    assert_equal "Stormlight Archive", stormlight.name
    assert_equal "Epic fantasy by Brandon Sanderson.", stormlight.description
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
    assert_not duplicate_series.valid?
    assert_includes duplicate_series.errors[:name], "has already been taken"
  end

  test "should have many books" do
    assert_respond_to @series, :books
  end

  test "should nullify associated books when destroyed" do
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
    new_name = "Updated Series"
    @series.update(name: new_name)
    assert_equal new_name, @series.reload.name
  end

  test "can be destroyed" do
    assert_difference "Series.count", -1 do
      @series.destroy
    end
  end
end
