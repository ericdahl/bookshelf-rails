# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_17_184146) do
  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "isbn_10"
    t.string "isbn_13"
    t.integer "publication_year"
    t.string "publisher"
    t.integer "page_count"
    t.text "description"
    t.string "cover_image_url"
    t.string "open_library_id"
    t.integer "series_id"
    t.string "status"
    t.integer "rating"
    t.text "comments"
    t.string "book_type"
    t.datetime "date_added"
    t.datetime "date_started"
    t.datetime "date_finished"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn_10"], name: "index_books_on_isbn_10", unique: true
    t.index ["isbn_13"], name: "index_books_on_isbn_13", unique: true
    t.index ["series_id"], name: "index_books_on_series_id"
  end

  create_table "series", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_series_on_name", unique: true
  end

  add_foreign_key "books", "series"
end
