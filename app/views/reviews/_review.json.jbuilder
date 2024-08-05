json.extract! review, :id, :book_id, :review, :score, :number_of_upvotes, :created_at, :updated_at
json.url review_url(review, format: :json)
