# db/seeds.rb
puts "Seeding database..."

# Series
stormlight = Series.find_or_create_by!(name: "Stormlight Archive") do |s|
  s.description = "Epic fantasy series by Brandon Sanderson."
end

dune_series = Series.find_or_create_by!(name: "Dune Saga") do |s|
  s.description = "Science fiction series by Frank Herbert."
end

wheel_of_time = Series.find_or_create_by!(name: "Wheel of Time") do |s|
  s.description = "Epic fantasy series by Robert Jordan."
end

mistborn = Series.find_or_create_by!(name: "Mistborn") do |s|
  s.description = "Fantasy series by Brandon Sanderson."
end

dark_tower = Series.find_or_create_by!(name: "The Dark Tower") do |s|
  s.description = "Dark fantasy series by Stephen King."
end

sword_of_truth = Series.find_or_create_by!(name: "Sword of Truth") do |s|
  s.description = "Fantasy series by Terry Goodkind."
end

harry_potter = Series.find_or_create_by!(name: "Harry Potter") do |s|
  s.description = "Fantasy series by J.K. Rowling."
end

riftwar = Series.find_or_create_by!(name: "Riftwar Saga") do |s|
  s.description = "Fantasy series by Raymond E. Feist."
end

hyperion = Series.find_or_create_by!(name: "Hyperion Cantos") do |s|
  s.description = "Science fiction series by Dan Simmons."
end

ender = Series.find_or_create_by!(name: "Ender's Game") do |s|
  s.description = "Science fiction series by Orson Scott Card."
end

alvin_maker = Series.find_or_create_by!(name: "Alvin Maker") do |s|
  s.description = "Fantasy series by Orson Scott Card."
end

the_land = Series.find_or_create_by!(name: "The Land") do |s|
  s.description = "LitRPG series by Aleron Kong."
end

dungeon_crawler = Series.find_or_create_by!(name: "Dungeon Crawler Carl") do |s|
  s.description = "LitRPG series by Matt Dinniman."
end

defiance = Series.find_or_create_by!(name: "Defiance of the Fall") do |s|
  s.description = "LitRPG series by JF Brink."
end

he_who_fights = Series.find_or_create_by!(name: "He Who Fights with Monsters") do |s|
  s.description = "LitRPG series by Travis Deverell."
end

awaken_online = Series.find_or_create_by!(name: "Awaken Online") do |s|
  s.description = "LitRPG series by Travis Bagwell."
end

azarinth = Series.find_or_create_by!(name: "Azarinth Healer") do |s|
  s.description = "LitRPG series by Rhaegar."
end

thirteenth_paladin = Series.find_or_create_by!(name: "The 13th Paladin") do |s|
  s.description = "Fantasy series by Torsten Weitze."
end

empyrean = Series.find_or_create_by!(name: "The Empyrean") do |s|
  s.description = "Fantasy series by Rebecca Yarros."
end

large_chests = Series.find_or_create_by!(name: "Everybody Loves Large Chests") do |s|
  s.description = "LitRPG series by Neven Illiev."
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

Book.find_or_create_by!(title: "The Eye of the World") do |b|
  b.author = "Robert Jordan"
  b.series = wheel_of_time
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1990
  b.page_count = 814
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Mistborn: The Final Empire") do |b|
  b.author = "Brandon Sanderson"
  b.series = mistborn
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2006
  b.page_count = 541
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "The Gunslinger") do |b|
  b.author = "Stephen King"
  b.series = dark_tower
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1982
  b.page_count = 224
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Wizard's First Rule") do |b|
  b.author = "Terry Goodkind"
  b.series = sword_of_truth
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1994
  b.page_count = 836
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Philosopher's Stone") do |b|
  b.author = "J.K. Rowling"
  b.series = harry_potter
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1997
  b.page_count = 309
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Magician") do |b|
  b.author = "Raymond E. Feist"
  b.series = riftwar
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1982
  b.page_count = 681
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Hyperion") do |b|
  b.author = "Dan Simmons"
  b.series = hyperion
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1989
  b.page_count = 482
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Ender's Game") do |b|
  b.author = "Orson Scott Card"
  b.series = ender
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1985
  b.page_count = 324
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Seventh Son") do |b|
  b.author = "Orson Scott Card"
  b.series = alvin_maker
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 1987
  b.page_count = 241
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "The Land: Founding") do |b|
  b.author = "Aleron Kong"
  b.series = the_land
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2015
  b.page_count = 512
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Dungeon Crawler Carl") do |b|
  b.author = "Matt Dinniman"
  b.series = dungeon_crawler
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2020
  b.page_count = 450
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Defiance of the Fall") do |b|
  b.author = "JF Brink"
  b.series = defiance
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2021
  b.page_count = 600
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "He Who Fights with Monsters") do |b|
  b.author = "Travis Deverell"
  b.series = he_who_fights
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2021
  b.page_count = 550
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Awaken Online: Catharsis") do |b|
  b.author = "Travis Bagwell"
  b.series = awaken_online
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2016
  b.page_count = 500
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Azarinth Healer Book One") do |b|
  b.author = "Rhaegar"
  b.series = azarinth
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2020
  b.page_count = 480
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Ahren") do |b|
  b.author = "Torsten Weitze"
  b.series = thirteenth_paladin
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2018
  b.page_count = 450
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Fourth Wing") do |b|
  b.author = "Rebecca Yarros"
  b.series = empyrean
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2023
  b.page_count = 528
  b.date_added = Time.current
end

Book.find_or_create_by!(title: "Morningwood") do |b|
  b.author = "Neven Illiev"
  b.series = large_chests
  b.status = "want_to_read"
  b.book_type = "ebook"
  b.publication_year = 2018
  b.page_count = 400
  b.date_added = Time.current
end

puts "Seeding complete!"
