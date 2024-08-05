class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.references :author, null: false, foreign_key: true
      t.string :name
      t.text :summary
      t.date :date_of_publication
      t.integer :number_of_sales

      t.timestamps
    end
  end
end
