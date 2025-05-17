require "test_helper"
require "webmock/minitest"

class Api::V1::OpenLibrarySearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Disable real HTTP requests
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  teardown do
    # Re-enable real HTTP requests after each test
    WebMock.allow_net_connect!
  end

  test "should get search" do
    # Mock the OpenLibrary API response
    stub_request(:get, "https://openlibrary.org/search.json")
      .with(
        query: {
          q: "The Great Gatsby",
          fields: "key,title,author_name,author_key,first_publish_year,isbn,publisher,cover_i,edition_key,number_of_pages_median,lccn,oclc",
          limit: 10
        },
        headers: {
          "User-Agent" => "BookshelfRailsApp/1.0 (your-email@example.com)"
        }
      )
      .to_return(
        status: 200,
        body: {
          docs: [
            {
              key: "/works/OL45804W",
              title: "The Great Gatsby",
              author_name: [ "F. Scott Fitzgerald" ],
              author_key: [ "OL26444A" ],
              first_publish_year: 1925,
              isbn: [ "9780743273565", "0743273567" ],
              publisher: [ "Scribner" ],
              cover_i: 1009264,
              edition_key: [ "OL2731668M" ],
              number_of_pages_median: 180
            }
          ]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    get api_v1_open_library_searches_search_url, params: { query: "The Great Gatsby" }
    assert_response :success

    # Verify the response structure
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal "The Great Gatsby", json_response.first["title"]
    assert_equal [ "F. Scott Fitzgerald" ], json_response.first["authors"]
  end
end
