class AddImagePathToAuthors < ActiveRecord::Migration[7.1]
  def change
    add_column :authors, :image_path, :string
  end
end
