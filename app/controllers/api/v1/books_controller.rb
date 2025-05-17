# app/controllers/api/v1/books_controller.rb
module Api
    module V1
      class BooksController < ApplicationController
        # Skip CSRF token verification for API requests (if you're not using session-based authentication for the API)
        # If you plan to use this API with external services or simple curl commands without complex auth, this is common.
        # For more secure APIs, you'd implement token-based authentication.
        skip_before_action :verify_authenticity_token
  
        # GET /api/v1/books
        def index
          @books = Book.all
          render json: @books
        end
  
        # GET /api/v1/books/:id
        def show
          @book = Book.find(params[:id])
          render json: @book
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Book not found" }, status: :not_found
        end
  
        # POST /api/v1/books
        def create
          @book = Book.new(book_params)
          if @book.save
            render json: @book, status: :created # 201 Created
          else
            render json: @book.errors, status: :unprocessable_entity # 422 Unprocessable Entity
          end
        end
  
        # PUT/PATCH /api/v1/books/:id
        def update
          @book = Book.find(params[:id])
          if @book.update(book_params)
            render json: @book
          else
            render json: @book.errors, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Book not found" }, status: :not_found
        end
  
        # DELETE /api/v1/books/:id
        def destroy
          @book = Book.find(params[:id])
          @book.destroy
          head :no_content # 204 No Content
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Book not found" }, status: :not_found
        end
  
        private
  
        def book_params
          # Strong Parameters: Whitelist the parameters you allow for create/update
          params.require(:book).permit(
            :title, :author, :isbn_10, :isbn_13,
            :publication_year, :publisher, :page_count,
            :description, :cover_image_url, :open_library_id,
            :series_id, :status, :rating, :comments, :book_type,
            :date_added, :date_started, :date_finished
          )
        end
      end
    end
  end