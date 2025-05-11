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

  def self.fetch_book(open_library_id)
    uri = URI("#{BASE_URL}/works/#{open_library_id}.json")
    response = make_request(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    book_data = JSON.parse(response.body)
    
    # Get author details if available
    author_data = nil
    if book_data['authors']&.first&.dig('author', 'key')
      author_uri = URI("#{BASE_URL}#{book_data['authors'].first['author']['key']}.json")
      author_response = make_request(author_uri)
      author_data = JSON.parse(author_response.body) if author_response.is_a?(Net::HTTPSuccess)
    end

    {
      'title' => book_data['title'],
      'author_name' => [author_data&.dig('name')].compact,
      'isbn' => book_data['isbn'],
      'cover_i' => book_data['covers']&.first,
      'first_publish_year' => book_data['first_publish_date']&.split('-')&.first
    }
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