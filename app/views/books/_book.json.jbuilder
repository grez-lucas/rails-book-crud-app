json.extract! book, :id, :author_id, :name, :summary, :date_of_publication, :number_of_sales, :created_at, :updated_at
json.url book_url(book, format: :json)
