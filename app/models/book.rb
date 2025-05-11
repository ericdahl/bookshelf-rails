class Book < ApplicationRecord
  belongs_to :author
  belongs_to :series, optional: true
end
