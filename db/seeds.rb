# db/seeds.rb
puts "Seeding database..."

# Series
stormlight = Series.find_or_create_by!(name: "Stormlight Archive") do |s|
  s.description = "Epic fantasy series by Brandon Sanderson."
end

dune_series = Series.find_or_create_by!(name: "Dune Saga") do |s|
  s.description = "Science fiction series by Frank Herbert."
end

# Books
Book.find_or_create_by!(title: "The Way of Kings") do |b|
  b.author = "Brandon Sanderson"
  b.series = stormlight
  b.status = "read"
  b.rating = 10
  b.book_type = "ebook"
  b.publication_year = 2010
  b.page_count = 1007
  b.date_added = Time.current
  b.date_finished = Time.current - 1.month
  b.comments = "Amazing start to the series."
end

Book.find_or_create_by!(title: "Words of Radiance") do |b|
  b.author = "Brandon Sanderson"
  b.series = stormlight
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2014
  b.page_count = 1087
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Dune") do |b|
  b.author = "Frank Herbert"
  b.series = dune_series
  b.status = "read"
  b.rating = 9
  b.book_type = "physical_book"
  b.publication_year = 1965
  b.page_count = 412
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Project Hail Mary") do |b|
  b.author = "Andy Weir"
  b.status = "currently_reading"
  b.book_type = "audiobook"
  b.publication_year = 2021
  b.page_count = 496 # Or duration for audiobook
  b.date_added = Time.current
  b.date_started = Time.current - 1.week
end

puts "Seeding complete!"