json.extract! book, :id, :title, :author_id, :series_id, :status, :open_library_id, :cover_url, :rating, :comments, :media_type, :published_date, :isbn, :genre, :page_count, :started_reading_at, :finished_reading_at, :created_at, :updated_at
json.url book_url(book, format: :json)
