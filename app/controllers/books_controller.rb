class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @sort_column = params[:sort] || session[:sort_column] || "title"
    @sort_direction = params[:direction] || session[:sort_direction] || "asc"

    # Store sort preferences in session
    session[:sort_column] = @sort_column if params[:sort]
    session[:sort_direction] = @sort_direction if params[:direction]

    @books = Book.all.order(@sort_column => @sort_direction)
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

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy
    redirect_to books_url, notice: "Book was successfully destroyed."
  end

  def update_status
    @book = Book.find(params[:id])
    @old_status = @book.status

    if @book.update(status: params[:status])
      # Set sort parameters for the partial
      @sort_column = session[:sort_column] || "title"
      @sort_direction = session[:sort_direction] || "asc"
      @books = Book.all.order(@sort_column => @sort_direction)

      respond_to do |format|
        format.turbo_stream # Will render update_status.turbo_stream.erb
        format.json { head :ok }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(
        :title, :author, :isbn_10, :isbn_13,
        :publication_year, :publisher, :page_count,
        :description, :cover_image_url, :open_library_id,
        :series_id, :status, :rating, :comments, :book_type,
        :date_added, :date_started, :date_finished
      )
    end
end
