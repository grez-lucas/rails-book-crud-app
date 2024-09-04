class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]
  
  def top_selling
    cache_key = "top_selling_books"

    @books = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      # Select top 50 top-selling books
      top_books_ids = Book.joins(:sales)
                          .select('books.id')
                          .group('books.id')
                          .order('SUM(sales.sales) DESC')
                          .limit(50)
                          .pluck(:id)

      @books = Book.where(id: top_books_ids)
                  .joins(:sales)
                  .select('books.id, books.name, books.date_of_publication, books.author_id, SUM(sales.sales) AS total_sales')
                  .group('books.id, books.name, books.date_of_publication, books.author_id')

      
      @books = @books.map do |book|
        # Total de ventas del autor
        total_author_sales = Book.joins(:sales)
                                  .where(author_id: book.author_id)
                                  .group('books.author_id')
                                  .sum('sales.sales')[book.author_id] || 0

        year_of_publication = book.date_of_publication.year
        top_5_year_sales = Sale.joins(:book)
                           .where("EXTRACT(YEAR FROM date_of_publication) = ?", year_of_publication)
                           .group(:book_id)
                           .order('SUM(sales.sales) DESC')
                           .limit(5)
                           .pluck(:book_id)


        book.attributes.merge(
          'total_sales' => book.total_sales,
          'total_author_sales' => total_author_sales,
          'top_5_year_sales' => top_5_year_sales.include?(book.id)
        )
      end

      @books.sort_by! { |b| -b['total_sales']}
    end

    # Ordena los libros según el parámetro de sort
    case params[:sort]
    when 'total_sales'
      @books.sort_by! { |b| -b['total_sales'] }
    when 'name'
      @books.sort_by! { |b| -b['name'] }
    when 'author_sales'
      @books.sort_by! { |b| -b['total_author_sales'] }
    when 'date_of_publication'
      @books.sort_by! { |b| b['date_of_publication'] }
    else
      @books.sort_by! { |b| -b['total_sales'] } # Default sorting
    end

    # Paginación
    @books = Kaminari.paginate_array(@books).page(params[:page]).per(10)

    # Log source of query
    source = Rails.cache.exist?(cache_key) ? "redis" : "database (no cache)"
    Rails.logger.info "Top selling data fetched from #{source}"
  end
  
  def top_rated
    # Verifica si ya tenemos los IDs de los 10 mejores libros en la sesión
    if session[:top_rated_books_ids].blank?
      # Selecciona los 10 libros con la puntuación promedio más alta
      top_books_ids = Book.joins(:reviews)
                          .select('books.id')
                          .group('books.id')
                          .order('AVG(reviews.score) DESC')
                          .limit(10)
                          .pluck(:id)
  
      # Guarda los IDs en la sesión
      session[:top_rated_books_ids] = top_books_ids
    end
  
    # Recupera los libros usando los IDs guardados en la sesión
    @books = Book.where(id: session[:top_rated_books_ids])
                 .joins(:reviews)
                 .select('books.id, books.name, books.date_of_publication, books.author_id, AVG(reviews.score) as average_score')
                 .group('books.id')
  
    # Ordena los libros basados en el parámetro de ordenamiento
    case params[:sort]
    when 'average_score'
      @books = @books.order('average_score DESC')
    when 'name'
      @books = @books.order('books.name ASC')
    when 'date_of_publication'
      @books = @books.order('books.date_of_publication DESC')
    else
      @books = @books.order('average_score DESC') # Default sorting
    end
  end
  

  # GET /books or /books.json
  def index
    @query = params[:query]
    @books = Book.search_by_summary(@query).page(params[:page]).per(10)
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new

    @possible_authors = Author.all
  end

  # GET /books/1/edit
  def edit
    @possible_authors = Author.all

  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to book_url(@book), notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to book_url(@book), notice: "Book was successfully updated." }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_url, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def sort_column
      %w[name author average_score date_of_publication].include?(params[:sort]) ? params[:sort] : 'average_score'
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:author_id, :name, :summary, :date_of_publication, :number_of_sales)
    end
end
