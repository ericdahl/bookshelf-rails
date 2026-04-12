module Api
  module V1
    class BooksController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_token!

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
          render json: @book, status: :created
        else
          render json: @book.errors, status: :unprocessable_entity
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
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Book not found" }, status: :not_found
      end

      private

      def authenticate_api_token!
        expected = Rails.application.credentials.api_token || ENV["API_TOKEN"]
        provided  = request.headers["X-Api-Token"]

        unless expected.present? && provided.present? &&
               ActiveSupport::SecurityUtils.secure_compare(provided, expected)
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

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
  end
end
