class AddImageToAuthors < ActiveRecord::Migration[7.1]
  def change
    add_column :authors, :image, :string
  end
end
