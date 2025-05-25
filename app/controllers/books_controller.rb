require "httparty"

class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # Temporary in-memory store for last deleted book (for demo purposes)
  @@last_deleted_book = nil

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
    @@last_deleted_book = @book.dup
    @@last_deleted_book.attributes = @book.attributes
    @book_title = @book.title
    @book_status = @book.status
    @book_id = @book.id
    @book.destroy
    respond_to do |format|
      format.turbo_stream do
        @sort_column = session[:sort_column] || "title"
        @sort_direction = session[:sort_direction] || "asc"
        @books = Book.all.order(@sort_column => @sort_direction)
        render turbo_stream: [
          turbo_stream.replace(
            "#{@book_status}_section",
            partial: "status_section",
            locals: { status: @book_status, title: status_title(@book_status), books: @books.select { |book| book.status == @book_status } }
          ),
          turbo_stream.replace(
            "notice",
            partial: "undo_notice",
            locals: { book_title: @book_title, book_id: @book_id, book_status: @book_status }
          )
        ]
      end
      format.html { redirect_to books_url, notice: "Book was successfully destroyed." }
    end
  end

  def restore
    if @@last_deleted_book
      restored_book = Book.create(@@last_deleted_book.attributes.except('id', 'created_at', 'updated_at'))
      @book_status = restored_book.status
      @sort_column = session[:sort_column] || "title"
      @sort_direction = session[:sort_direction] || "asc"
      @books = Book.all.order(@sort_column => @sort_direction)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "#{@book_status}_section",
              partial: "status_section",
              locals: { status: @book_status, title: status_title(@book_status), books: @books.select { |book| book.status == @book_status } }
            ),
            turbo_stream.replace(
              "notice",
              partial: "undo_notice_restored",
              locals: { book_title: restored_book.title }
            )
          ]
        end
        format.html { redirect_to books_url, notice: "Restored '#{restored_book.title}'" }
      end
      @@last_deleted_book = nil
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to books_url, alert: "No book to restore." }
      end
    end
  end

  def search
    @query = params[:query]
    @search_results = []

    if @query.present?
      begin
        # Use the existing API endpoint
        api_url = "#{request.base_url}/api/v1/search"
        Rails.logger.info "Making API request to: #{api_url} with query: #{@query}"
        response = HTTParty.get(api_url, query: { query: @query })

        if response.success?
          @search_results = response.parsed_response
          Rails.logger.info "API response successful, found #{@search_results.size} results"
          # Filter out books that are already in the user's collection
          existing_book_ids = Book.pluck(:open_library_id).compact
          Rails.logger.info "Existing book IDs: #{existing_book_ids}"
          @search_results = @search_results.reject { |book| existing_book_ids.include?(book["open_library_id"]) }
          Rails.logger.info "After filtering, #{@search_results.size} results remain"
        else
          Rails.logger.error "API request failed with status: #{response.code}"
        end
      rescue => e
        Rails.logger.error "Search error: #{e.message}"
        @search_results = []
      end
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("search-results", partial: "search_results") }
      format.html { render turbo_stream: turbo_stream.replace("search-results", partial: "search_results") }
    end
  end

  def add_from_search
    @status = params[:status]

    # Create book from search data
    @book = Book.new(
      title: params[:title],
      author: params[:authors],
      publication_year: params[:publication_year],
      open_library_id: params[:open_library_id],
      status: @status,
      book_type: "physical_book",
      date_added: Time.current
    )

    if @book.save
      # Refresh the books data for the view
      @sort_column = session[:sort_column] || "title"
      @sort_direction = session[:sort_direction] || "asc"
      @books = Book.all.order(@sort_column => @sort_direction)

      # Clear search results
      @query = ""
      @search_results = []

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("#{@status}_section", partial: "status_section", locals: {
              status: @status,
              title: status_title(@status),
              books: @books.select { |book| book.status == @status }
            }),
            turbo_stream.replace("search-results", partial: "search_results")
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
      end
    end
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

    def format_authors(authors)
      return "Unknown Author" if authors.blank?

      if authors.is_a?(Array)
        authors.join(", ")
      else
        authors.to_s
      end
    end

    def status_title(status)
      {
        "want_to_read" => "Want to Read",
        "currently_reading" => "Currently Reading",
        "read" => "Read"
      }[status] || status.humanize
    end
end
