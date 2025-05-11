require 'net/http'
require 'json'

class OpenLibraryService
  BASE_URL = 'https://openlibrary.org'
  
  def self.search(query)
    uri = URI("#{BASE_URL}/search.json")
    params = {
      q: query,
      fields: 'key,title,author_name,isbn,cover_i,author_key,first_publish_year',
      limit: 20
    }
    uri.query = URI.encode_www_form(params)

    response = make_request(uri)
    return [] unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  private

  def self.make_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/json'
    request['User-Agent'] = 'BookshelfRails/1.0'

    http.request(request)
  rescue StandardError => e
    Rails.logger.error("OpenLibrary API request failed: #{e.message}")
    nil
  end
end 