class AuthorsController < ApplicationController
  before_action :set_author, only: %i[show edit update destroy]
  after_action :invalidate_author_cache, only: %i[update destroy]

  # GET /authors or /@authors.json
  def index
    @authors = Author.all

    # Filtering
    @authors = @authors.where('name ILIKE ?', "%#{params[:name]}%") if params[:name].present?
    if params[:books_count].present?
      @authors = @authors.left_joins(:books).group(:id)
                        .having('COUNT(books.id) >= ?', params[:books_count].to_i)
    end
    if params[:average_score].present?
      @authors = @authors.left_joins(books: :reviews).group(:id)
                        .having('AVG(reviews.score) >= ?', params[:average_score].to_f)
    end
    if params[:total_sales].present?
      @authors = @authors.left_joins(books: :sales).group(:id)
                        .having('SUM(sales.sales) >= ?', params[:total_sales].to_i)
    end
    if params[:date_of_birth].present?
      @authors = @authors.where('EXTRACT(YEAR FROM date_of_birth) >= ?', params[:date_of_birth].to_i)
    end
    if params[:country_of_origin].present?
      @authors = @authors.where('country_of_origin ILIKE ?', "%#{params[:country_of_origin]}%")
    end

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
    author_cache_key = "author_#{params[:id]}_details"

    author_data = Rails.cache.fetch(author_cache_key, expires_in: 12.hours) do
      data = fetch_author_data
      data
    end

    @book_count = author_data[:book_count].to_i
    @average_score = author_data[:average_score]
    @total_sales = author_data[:total_sales]

    source = Rails.cache.exist?(author_cache_key) ? "redis" : "database (no cache)"
    Rails.logger.info "Author data fetched from #{source}"
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors or /@authors.json
  def create
    @author = Author.new(author_params)
  
    if author_params[:image].present?
      # Attach the image using ActiveStorage
      image = author_params[:image]
      @author.image.attach(image)
      
      # Save the image path or ActiveStorage URL
      #@author.image_path = url_for(@author.image) if @author.image.attached?
    end
  
    respond_to do |format|
      if @author.save
        format.html { redirect_to author_url(@author), notice: 'Author was successfully created.' }
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
        format.html { redirect_to author_url(author), notice: 'Author was successfully updated.' }
        format.json { render :show, status: :ok, location: author }
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
      format.html { redirect_to @authors_url, notice: 'Author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def fetch_author_data
    {
      author: @author.attributes,
      book_count: @author.books.count,
      average_score: calculate_average_score,
      total_sales: calculate_total_sales
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_author
    @author = Author.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def author_params
    params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description, :image, :image_path)
  end  

  def calculate_average_score
    average_score = @author.books.joins(:reviews).average('reviews.score').to_f
    average_score.nan? ? 0 : average_score
  end

  def calculate_total_sales
    @author.books.joins(:sales).sum('sales.sales')
  end

  def invalidate_author_cache
    Rails.cache.delete("author_#{params[:id]}_details") # Rails.cache handles the case where no cache is found
  end

  def save_uploaded_file(uploaded_file)
    Dir.mkdir(Rails.root.join('uploads')) unless Dir.exist?(Rails.root.join('uploads'))
    
    file_name = "#{SecureRandom.uuid}_#{uploaded_file.original_filename}"
    file_path = Rails.root.join('uploads', file_name)
    
    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    "/uploads/#{file_name}"
  end
end
