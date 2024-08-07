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
    short_description: Faker::Lorem.paragraph
  )
end

# Crear 300 libros, asignando un autor al azar a cada uno
300.times do
  author = Author.order('RANDOM()').first  # Obtener un autor al azar
  book = Book.create!(
    name: Faker::Book.title,
    summary: Faker::Lorem.paragraph,
    date_of_publication: Faker::Date.between(from: '1900-01-01', to: Date.today),
    number_of_sales: Faker::Number.between(from: 1000, to: 500000),
    author_id: author.id  # Usar el ID del autor
  )

  # Crear entre 1 y 10 reseñas para cada libro
  rand(1..10).times do
    Review.create!(
      book: book,
      review: Faker::Lorem.paragraph,
      score: Faker::Number.between(from: 1, to: 5),
      number_of_upvotes: Faker::Number.between(from: 0, to: 100)
    )
  end

  # Crear ventas para los últimos 5 años
  5.times do |i|
    Sale.create!(
      book: book,
      year: Faker::Date.between(from: Date.new(Date.today.year - i, 1, 1), to: Date.new(Date.today.year - i, 12, 31)),
      sales: Faker::Number.between(from: 1000, to: 100000)
    )
  end
end

puts "Seed completado: #{Author.count} autores, #{Book.count} libros, #{Review.count} reseñas, y #{Sale.count} ventas creadas."
