class Author < ApplicationRecord
  has_many :books, dependent: :destroy
  has_one_attached :image
  attr_accessor :image_path
end
