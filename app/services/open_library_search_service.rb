require "httparty"

class OpenLibrarySearchService
  SEARCH_URL = "https://openlibrary.org/search.json".freeze
  FIELDS = %w[
    key title author_name author_key first_publish_year isbn
    publisher cover_i edition_key number_of_pages_median lccn oclc
  ].join(",").freeze

  def search(query)
    start_time = Time.current
    response = HTTParty.get(
      SEARCH_URL,
      query: { q: query, fields: FIELDS, limit: 10 },
      headers: { "User-Agent" => "BookshelfRailsApp/1.0" },
      timeout: 10
    )
    duration = ((Time.current - start_time) * 1000).round(2)

    if response.success?
      results = parse_response(response.parsed_response)
      Rails.logger.info "[OpenLibrary] #{duration}ms, #{results.size} results for #{query.inspect}"
      results
    else
      Rails.logger.error "[OpenLibrary] Failed with status #{response.code}: #{response.body}"
      []
    end
  rescue HTTParty::Error => e
    Rails.logger.error "[OpenLibrary] HTTParty error: #{e.message}"
    []
  rescue StandardError => e
    Rails.logger.error "[OpenLibrary] Unexpected error: #{e.message}"
    []
  end

  private

  def parse_response(data)
    return [] unless data && data["docs"]

    data["docs"].map do |doc|
      isbns = doc["isbn"].is_a?(Array) ? doc["isbn"] : []

      {
        "open_library_id" => doc["key"]&.split("/")&.last,
        "title" => doc["title"],
        "authors" => doc["author_name"].is_a?(Array) ? doc["author_name"] : [ doc["author_name"] ].compact,
        "author_olids" => doc["author_key"].is_a?(Array) ? doc["author_key"] : [ doc["author_key"] ].compact,
        "publication_year" => doc["first_publish_year"],
        "isbn_13" => isbns.find { |isbn| isbn.match?(/^\d{13}$/) || isbn.match?(/^978\d{10}$/) } ||
                     isbns.find { |isbn| isbn.match?(/^978/) },
        "isbn_10" => isbns.find { |isbn| isbn.match?(/^\d{9}[\dX]$/) || isbn.match?(/^\d{10}$/) },
        "publishers" => doc["publisher"].is_a?(Array) ? doc["publisher"] : [ doc["publisher"] ].compact,
        "page_count" => doc["number_of_pages_median"],
        "cover_image_url_large" => doc["cover_i"] ? "https://covers.openlibrary.org/b/id/#{doc['cover_i']}-L.jpg" : nil,
        "cover_image_url_medium" => doc["cover_i"] ? "https://covers.openlibrary.org/b/id/#{doc['cover_i']}-M.jpg" : nil,
        "edition_olids" => doc["edition_key"].is_a?(Array) ? doc["edition_key"] : [ doc["edition_key"] ].compact
      }
    end
  end
end
