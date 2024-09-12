class Book < ApplicationRecord
  belongs_to :author
  has_many :reviews, dependent: :destroy
  has_many :sales, dependent: :destroy
  has_one_attached :cover

  # Search bar logic for words in description
  scope :search_by_summary, ->(query) {
    if query.present?
      words = query.downcase.split(' ')
      where(
        words.map { |word| "summary ILIKE ?" }.join(' OR '),
        *words.map { |word| "%#{word}%" }
      )
    else
      all
    end
  }
end
