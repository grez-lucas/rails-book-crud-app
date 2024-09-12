class AddCoverPathToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :cover_path, :string
  end
end
