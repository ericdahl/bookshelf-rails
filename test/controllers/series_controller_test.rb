require "test_helper"

class SeriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @series = series(:one)
  end

  # ---------------------------------------------------------------------------
  # index
  # ---------------------------------------------------------------------------

  test "should get index" do
    get series_index_url
    assert_response :success
  end

  # ---------------------------------------------------------------------------
  # new / create
  # ---------------------------------------------------------------------------

  test "should get new" do
    get new_series_url
    assert_response :success
  end

  test "should create series" do
    assert_difference("Series.count") do
      post series_index_url, params: { series: { name: "Unique Test Series", description: "A test series." } }
    end
    assert_redirected_to series_url(Series.last)
    assert_equal "Unique Test Series", Series.last.name
  end

  test "should not create series without a name" do
    assert_no_difference("Series.count") do
      post series_index_url, params: { series: { name: "", description: "No name" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not create series with a duplicate name" do
    assert_no_difference("Series.count") do
      post series_index_url, params: { series: { name: @series.name, description: "Duplicate" } }
    end
    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # show
  # ---------------------------------------------------------------------------

  test "should show series" do
    get series_url(@series)
    assert_response :success
  end

  # ---------------------------------------------------------------------------
  # edit / update
  # ---------------------------------------------------------------------------

  test "should get edit" do
    get edit_series_url(@series)
    assert_response :success
  end

  test "should update series and persist changes to database" do
    new_name = "A Different Series Name"
    patch series_url(@series), params: { series: { name: new_name, description: "Updated description." } }
    assert_redirected_to series_url(@series)
    @series.reload
    assert_equal new_name, @series.name
    assert_equal "Updated description.", @series.description
  end

  test "should not update series with blank name" do
    original_name = @series.name
    patch series_url(@series), params: { series: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal original_name, @series.reload.name
  end

  test "should not update series to a name already taken by another series" do
    other_series = series(:lotr)
    patch series_url(@series), params: { series: { name: other_series.name } }
    assert_response :unprocessable_entity
    assert_not_equal other_series.name, @series.reload.name
  end

  # ---------------------------------------------------------------------------
  # destroy
  # ---------------------------------------------------------------------------

  test "should destroy series" do
    assert_difference("Series.count", -1) do
      delete series_url(@series)
    end
    assert_redirected_to series_index_url
  end

  test "should nullify books when series is destroyed" do
    book = Book.create!(title: "Orphan Book", series: @series, status: :want_to_read, book_type: :physical_book)
    delete series_url(@series)
    assert_nil book.reload.series_id
  end
end
