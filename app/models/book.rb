class Book < ApplicationRecord
  include OpenSearch::Model
  include OpenSearch::Model::Callbacks

  belongs_to :author
  has_many :reviews, dependent: :destroy
  has_many :sales, dependent: :destroy


  settings do
    mappings dynamic: 'false' do
      indexes :name, type: :text
      indexes :summary, type: :text
      indexes :date_of_publication, type: :date
      indexes :author_name, type: :text
    end
  end

  def as_indexed_json(options = {})
    as_json(
      include: { author: { only: :name } }
    ).merge(author_name: author.name)
  end
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
