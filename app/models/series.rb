class Series < ApplicationRecord
    has_many :books, dependent: :nullify # Or :destroy, depending on how you want to handle series deletion

    validates :name, presence: true, uniqueness: true
end
