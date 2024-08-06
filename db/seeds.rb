# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

# Limpia las tablas antes de poblarlas
Review.destroy_all
Sale.destroy_all
Book.destroy_all
Author.destroy_all

# Crear 50 autores
50.times do
  Author.create!(
    name: Faker::Book.author,
    date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 90),
    country_of_origin: Faker::Address.country,
    description: Faker::Lorem.paragraph
  )
end

# Crear 300 libros, asignando un autor al azar a cada uno
300.times do
  book = Book.create!(
    name: Faker::Book.title,
    summary: Faker::Lorem.paragraph,
    publication_date: Faker::Date.between(from: '1900-01-01', to: Date.today),
    sales: Faker::Number.between(from: 1000, to: 500000),
    author: Author.order('RANDOM()').first
  )

  # Crear entre 1 y 10 reseñas para cada libro
  rand(1..10).times do
    Review.create!(
      book: book,
      review: Faker::Lorem.paragraph,
      score: Faker::Number.between(from: 1, to: 5),
      up_votes: Faker::Number.between(from: 0, to: 100)
    )
  end

  # Crear ventas para los últimos 5 años
  5.times do |i|
    Sale.create!(
      book: book,
      year: Date.today.year - i,
      sales: Faker::Number.between(from: 1000, to: 100000)
    )
  end
end

puts "Seed completado: #{Author.count} autores, #{Book.count} libros, #{Review.count} reseñas, y #{Sale.count} ventas creadas."
