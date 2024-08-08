class AuthorsController < ApplicationController
  before_action :set_author, only: %i[ show edit update destroy ]

  # GET /authors or /authors.json
  def index
    @authors = Author.all
    case params[:sort]
    when 'name'
      @authors = @authors.order(:name)
    when 'books_count'
      @authors = @authors.left_joins(:books).group(:id).order('COUNT(books.id) DESC')
    when 'average_score'
      @authors = @authors.left_joins(books: :reviews).group(:id).order('AVG(reviews.score) DESC')
    when 'total_sales'
      @authors = @authors.left_joins(books: :sales).group(:id).order('SUM(sales.sales) DESC')
    when 'date_of_birth'
      @authors = @authors.order(:date_of_birth)
    end
  end

  # GET /authors/1 or /authors/1.json
  def show
    @author = Author.find(params[:id])

    # Calcula el número de libros publicados
    @book_count = @author.books.count

    # Calcula la puntuación promedio de los libros del autor
    @average_score = @author.books.joins(:reviews)
                                .average('reviews.score')
                                .to_f
    @average_score = @average_score.nan? ? 0 : @average_score

    # Calcula las ventas totales de los libros del autor
    @total_sales = @author.books.joins(:sales)
                              .sum('sales.sales')
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors or /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.html { redirect_to author_url(@author), notice: "Author was successfully created." }
        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1 or /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html { redirect_to author_url(@author), notice: "Author was successfully updated." }
        format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1 or /authors/1.json
  def destroy
    @author.destroy!

    respond_to do |format|
      format.html { redirect_to authors_url, notice: "Author was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def author_params
      params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description)
    end
end
