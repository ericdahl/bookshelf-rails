class Book < ApplicationRecord
  belongs_to :series, optional: true

  enum :status, { want_to_read: "want_to_read", currently_reading: "currently_reading", read: "read" }
  enum :book_type, { physical_book: "physical_book", ebook: "ebook", audiobook: "audiobook" }

  validates :title, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validates :status, presence: true # Or decide if a book can be added without an initial status
  # validates :book_type, presence: true # Optional, depending on your needs

  # Consider uniqueness validation for ISBNs if they are critical and reliable
  # validates :isbn_13, uniqueness: true, allow_blank: true
  # validates :isbn_10, uniqueness: true, allow_blank: true
end
