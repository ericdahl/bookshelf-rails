class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @books = Book.all
  end

  # GET /books/search
  def search
    @query = params[:q]
    return unless @query.present?

    # Search in local database using SQLite-compatible case-insensitive search
    @local_books = Book.joins(:author)
                      .where("LOWER(books.title) LIKE ? OR LOWER(authors.name) LIKE ?", 
                            "%#{@query.downcase}%", 
                            "%#{@query.downcase}%")
    
    # Search in OpenLibrary
    ol_results = OpenLibraryService.search(@query)
    
    # Transform OpenLibrary results
    @open_library_books = ol_results['docs'].map do |doc|
      {
        open_library_id: doc['key'].split('/').last,
        title: doc['title'],
        author: doc['author_name']&.join(', '),
        isbn: doc['isbn']&.first,
        cover_url: doc['cover_i'] ? "https://covers.openlibrary.org/b/id/#{doc['cover_i']}-M.jpg" : nil,
        published_year: doc['first_publish_year']
      }
    end

    # Check which OpenLibrary books already exist in our database
    existing_books = Book.where(open_library_id: @open_library_books.map { |b| b[:open_library_id] })
    @existing_book_ids = existing_books.map(&:open_library_id)

    respond_to do |format|
      format.html
      format.json { render json: { local_books: @local_books, open_library_books: @open_library_books } }
    end
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
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
        format.html { redirect_to @book, notice: "Book was successfully updated." }
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
      format.html { redirect_to books_path, status: :see_other, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :author_id, :series_id, :status, :open_library_id, :cover_url, :rating, :comments, :media_type, :published_date, :isbn, :genre, :page_count, :started_reading_at, :finished_reading_at)
    end
end
