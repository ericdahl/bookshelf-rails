require "application_system_test_case"

class SeriesTest < ApplicationSystemTestCase
  setup do
    @series = series(:one)
  end

  test "visiting the index" do
    visit series_url
    assert_selector "h1", text: "Series"
  end

  test "should create series" do
    visit series_url
    click_on "New series"

    fill_in "Description", with: @series.description
    fill_in "Name", with: @series.name
    click_on "Create Series"

    assert_text "Series was successfully created"
    click_on "Back"
  end

  test "should update Series" do
    visit series_url(@series)
    click_on "Edit this series", match: :first

    fill_in "Description", with: @series.description
    fill_in "Name", with: @series.name
    click_on "Update Series"

    assert_text "Series was successfully updated"
    click_on "Back"
  end

  test "should destroy Series" do
    visit series_url(@series)
    accept_confirm { click_on "Destroy this series", match: :first }

    assert_text "Series was successfully destroyed"
  end
end
