require "test_helper"
require "webmock/minitest"

class Api::V1::OpenLibrarySearchesControllerTest < ActionDispatch::IntegrationTest
  OPENLIBRARY_URL = "https://openlibrary.org/search.json"

  setup do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  teardown do
    WebMock.allow_net_connect!
  end

  # ---------------------------------------------------------------------------
  # Happy path
  # ---------------------------------------------------------------------------

  test "should search and return parsed results" do
    stub_openlibrary(
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
      }
    )

    get "/api/v1/search", params: { query: "The Great Gatsby" }
    assert_response :success

    result = JSON.parse(response.body).first
    assert_equal "OL45804W",            result["open_library_id"]
    assert_equal "The Great Gatsby",    result["title"]
    assert_equal [ "F. Scott Fitzgerald" ], result["authors"]
    assert_equal 1925,                  result["publication_year"]
    assert_equal "9780743273565",       result["isbn_13"]
    assert_equal "0743273567",          result["isbn_10"]
    assert_equal [ "Scribner" ],        result["publishers"]
    assert_equal 180,                   result["page_count"]
    assert_match %r{covers\.openlibrary\.org.*1009264-L}, result["cover_image_url_large"]
    assert_match %r{covers\.openlibrary\.org.*1009264-M}, result["cover_image_url_medium"]
  end

  test "should return multiple results" do
    stub_openlibrary(
      status: 200,
      body: {
        docs: [
          { key: "/works/OL1W", title: "Book One", author_name: [ "Author A" ] },
          { key: "/works/OL2W", title: "Book Two", author_name: [ "Author B" ] }
        ]
      }
    )

    get "/api/v1/search", params: { query: "book" }
    assert_response :success
    assert_equal 2, JSON.parse(response.body).length
  end

  # ---------------------------------------------------------------------------
  # Missing / empty query
  # ---------------------------------------------------------------------------

  test "should return 400 when query param is missing" do
    get "/api/v1/search"
    assert_response :bad_request
    assert_equal "Search query is required", JSON.parse(response.body)["error"]
  end

  test "should return 400 when query param is empty string" do
    get "/api/v1/search", params: { query: "" }
    assert_response :bad_request
    assert_equal "Search query is required", JSON.parse(response.body)["error"]
  end

  # ---------------------------------------------------------------------------
  # OpenLibrary API error responses
  # ---------------------------------------------------------------------------

  test "should return upstream error status when OpenLibrary returns 503" do
    stub_openlibrary(status: 503, body: "Service Unavailable")

    get "/api/v1/search", params: { query: "test" }
    assert_response 503
    assert_includes JSON.parse(response.body)["error"], "Failed to fetch data from OpenLibrary"
  end

  test "should return 500 when OpenLibrary returns 500" do
    stub_openlibrary(status: 500, body: "Internal Server Error")

    get "/api/v1/search", params: { query: "test" }
    assert_response 500
  end

  # ---------------------------------------------------------------------------
  # Network / timeout errors
  # ---------------------------------------------------------------------------

  test "should return 500 on HTTParty network error" do
    stub_request(:get, /openlibrary\.org\/search\.json/).to_raise(HTTParty::Error.new("connection refused"))

    get "/api/v1/search", params: { query: "test" }
    assert_response :internal_server_error
    assert_includes JSON.parse(response.body)["error"], "HTTParty error"
  end

  test "should return 500 on connection timeout" do
    stub_request(:get, /openlibrary\.org\/search\.json/).to_raise(Net::OpenTimeout)

    get "/api/v1/search", params: { query: "test" }
    assert_response :internal_server_error
  end

  # ---------------------------------------------------------------------------
  # Edge cases in response parsing
  # ---------------------------------------------------------------------------

  test "should return empty array when docs is empty" do
    stub_openlibrary(status: 200, body: { docs: [] })

    get "/api/v1/search", params: { query: "nothing" }
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "should return empty array when docs key is missing" do
    stub_openlibrary(status: 200, body: { numFound: 0 })

    get "/api/v1/search", params: { query: "nothing" }
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "should handle book with no author" do
    stub_openlibrary(
      status: 200,
      body: { docs: [ { key: "/works/OL1W", title: "Anonymous Book" } ] }
    )

    get "/api/v1/search", params: { query: "anonymous" }
    assert_response :success
    result = JSON.parse(response.body).first
    assert_equal "Anonymous Book", result["title"]
    assert_equal [], result["authors"]
    assert_nil result["publication_year"]
    assert_nil result["isbn_13"]
    assert_nil result["isbn_10"]
    assert_nil result["cover_image_url_large"]
  end

  test "should handle book with no cover image" do
    stub_openlibrary(
      status: 200,
      body: { docs: [ { key: "/works/OL2W", title: "No Cover Book", cover_i: nil } ] }
    )

    get "/api/v1/search", params: { query: "no cover" }
    assert_response :success
    result = JSON.parse(response.body).first
    assert_nil result["cover_image_url_large"]
    assert_nil result["cover_image_url_medium"]
  end

  test "should build correct cover image URLs when cover_i is present" do
    stub_openlibrary(
      status: 200,
      body: { docs: [ { key: "/works/OL3W", title: "Covered Book", cover_i: 42 } ] }
    )

    get "/api/v1/search", params: { query: "covered" }
    result = JSON.parse(response.body).first
    assert_equal "https://covers.openlibrary.org/b/id/42-L.jpg", result["cover_image_url_large"]
    assert_equal "https://covers.openlibrary.org/b/id/42-M.jpg", result["cover_image_url_medium"]
  end

  test "should extract open_library_id from the work key path" do
    stub_openlibrary(
      status: 200,
      body: { docs: [ { key: "/works/OL99999W", title: "Key Test" } ] }
    )

    get "/api/v1/search", params: { query: "key test" }
    result = JSON.parse(response.body).first
    assert_equal "OL99999W", result["open_library_id"]
  end

  test "should prefer isbn_13 over isbn_10 in isbn list" do
    stub_openlibrary(
      status: 200,
      body: {
        docs: [ {
          key: "/works/OL5W",
          title: "ISBN Test",
          isbn: [ "0743273567", "9780743273565" ]
        } ]
      }
    )

    get "/api/v1/search", params: { query: "isbn" }
    result = JSON.parse(response.body).first
    assert_equal "9780743273565", result["isbn_13"]
    assert_equal "0743273567",    result["isbn_10"]
  end

  private

  def stub_openlibrary(status:, body:)
    stub_request(:get, /openlibrary\.org\/search\.json/)
      .to_return(
        status: status,
        body: body.is_a?(String) ? body : body.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
