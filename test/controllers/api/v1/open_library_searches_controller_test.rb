require "test_helper"

class Api::V1::OpenLibrarySearchesControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get api_v1_open_library_searches_search_url
    assert_response :success
  end
end
