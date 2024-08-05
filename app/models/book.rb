class Book < ApplicationRecord
  belongs_to :author
  has_many :reviews, dependent: :destroy
  has_many :sales, dependent: :destroy
end
