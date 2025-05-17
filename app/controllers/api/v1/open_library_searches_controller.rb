# app/controllers/api/v1/open_library_searches_controller.rb
require 'httparty' # Or 'faraday' if you chose that

module Api
  module V1
    class OpenLibrarySearchesController < ApplicationController
      # If you have API authentication for your own API, apply it as needed.
      # For now, skipping CSRF for simplicity if this is a pure API controller.
      skip_before_action :verify_authenticity_token, raise: false # Use `raise: false` to avoid warnings on GET

      OPEN_LIBRARY_SEARCH_URL = 'https://openlibrary.org/search.json'.freeze
      # Consider adding more fields if needed, e.g., language, subject, first_sentence
      FIELDS_TO_REQUEST = [
        'key', # Work OLID
        'title',
        'author_name',
        'author_key', # Author OLIDs
        'first_publish_year',
        'isbn', # Array of ISBNs (10 and 13)
        'publisher', # Array of publishers
        'cover_i', # Cover ID
        'edition_key', # OLIDs for editions
        'number_of_pages_median', # Often available for works
        'lccn', # Library of Congress Control Number
        'oclc'  # OCLC Number
      ].join(',')

      def search
        query = params[:query]

        unless query.present?
          render json: { error: 'Search query is required' }, status: :bad_request
          return
        end

        begin
          # Set a User-Agent as per OpenLibrary recommendations for frequent use
          headers = { "User-Agent" => "BookshelfRailsApp/1.0 (your-email@example.com)" } # Replace with your app name and contact
          
          request_params = {
            q: query,
            fields: FIELDS_TO_REQUEST,
            limit: 10 # Adjust as needed
          }

          Rails.logger.info "[OpenLibrary API] Making request to #{OPEN_LIBRARY_SEARCH_URL} with params: #{request_params.inspect}"

          start_time = Time.current
          response = HTTParty.get(
            OPEN_LIBRARY_SEARCH_URL,
            query: request_params,
            headers: headers,
            timeout: 10 # Set a timeout in seconds
          )
          end_time = Time.current
          duration = ((end_time - start_time) * 1000).round(2) # Convert to milliseconds

          if response.success?
            results = parse_open_library_response(response.parsed_response)
            Rails.logger.info "[OpenLibrary API] Request completed in #{duration}ms with status: #{response.code} (#{results.size} results)"
            render json: results
          else
            Rails.logger.error "[OpenLibrary API] Failed with status #{response.code}: #{response.body}"
            render json: { error: 'Failed to fetch data from OpenLibrary', details: response.body }, status: response.code
          end
        rescue HTTParty::Error => e # Covers network errors, timeouts, etc.
          Rails.logger.error "[OpenLibrary API] HTTParty error: #{e.message}"
          render json: { error: "HTTParty error: #{e.message}" }, status: :internal_server_error
        rescue StandardError => e
          Rails.logger.error "[OpenLibrary API] Unexpected error: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        end
      end

      private

      def parse_open_library_response(open_library_data)
        return [] unless open_library_data && open_library_data['docs']

        open_library_data['docs'].map do |doc|
          # Helper to safely extract first element from an array or return nil
          first_or_nil = ->(arr) { arr.is_a?(Array) ? arr.first : nil }

          # Extract and normalize data
          open_library_id = doc['key']&.split('/')&.last # Get just the ID part like OL45804W
          isbns = doc['isbn'].is_a?(Array) ? doc['isbn'] : []

          {
            open_library_id: open_library_id,
            title: doc['title'],
            authors: doc['author_name'].is_a?(Array) ? doc['author_name'] : [doc['author_name']].compact,
            author_olids: doc['author_key'].is_a?(Array) ? doc['author_key'] : [doc['author_key']].compact,
            publication_year: doc['first_publish_year'],
            # Prioritize 13-digit ISBNs, then 10-digit
            isbn_13: isbns.find { |isbn| isbn.match?(/^\d{13}$/) || isbn.match?(/^978\d{10}$/) } || isbns.find { |isbn| isbn.match?(/^978/) }, # Sometimes 13-digit ISBNs are not perfectly formatted
            isbn_10: isbns.find { |isbn| isbn.match?(/^\d{9}[\dX]$/) || isbn.match?(/^\d{10}$/) },
            publishers: doc['publisher'].is_a?(Array) ? doc['publisher'] : [doc['publisher']].compact,
            page_count: doc['number_of_pages_median'],
            cover_image_url_large: doc['cover_i'] ? "https://covers.openlibrary.org/b/id/#{doc['cover_i']}-L.jpg" : nil,
            cover_image_url_medium: doc['cover_i'] ? "https://covers.openlibrary.org/b/id/#{doc['cover_i']}-M.jpg" : nil,
            edition_olids: doc['edition_key'].is_a?(Array) ? doc['edition_key'] : [doc['edition_key']].compact
            # Note: Description is usually not available in the search results.
            # You might need another API call to get a specific work/edition for detailed descriptions.
            # e.g., https://openlibrary.org/works/#{open_library_id}.json
          }
        end.compact # Remove any nil results if a doc was unparsable (though map should handle it)
      end
    end
  end
end