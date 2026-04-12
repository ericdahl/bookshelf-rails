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

ActiveRecord::Schema[8.1].define(version: 2026_04_12_000001) do
  create_table "books", force: :cascade do |t|
    t.string "author"
    t.string "book_type", null: false
    t.text "comments"
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.datetime "date_added"
    t.datetime "date_finished"
    t.datetime "date_started"
    t.text "description"
    t.string "isbn_10"
    t.string "isbn_13"
    t.string "open_library_id"
    t.integer "page_count"
    t.integer "publication_year"
    t.string "publisher"
    t.integer "rating"
    t.integer "series_id"
    t.string "status", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn_10"], name: "index_books_on_isbn_10", unique: true
    t.index ["isbn_13"], name: "index_books_on_isbn_13", unique: true
    t.index ["open_library_id"], name: "index_books_on_open_library_id"
    t.index ["series_id"], name: "index_books_on_series_id"
    t.index ["status"], name: "index_books_on_status"
  end

  create_table "series", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_series_on_name", unique: true
  end

  add_foreign_key "books", "series"
end
