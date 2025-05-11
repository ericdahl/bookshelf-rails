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

ActiveRecord::Schema[8.0].define(version: 2025_05_11_171428) do
  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.integer "author_id", null: false
    t.integer "series_id"
    t.string "open_library_id"
    t.string "cover_url"
    t.integer "rating"
    t.text "comments"
    t.date "published_date"
    t.string "isbn"
    t.string "genre"
    t.integer "page_count"
    t.datetime "started_reading_at"
    t.datetime "finished_reading_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "media_type", default: 0, null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["media_type"], name: "index_books_on_media_type"
    t.index ["open_library_id"], name: "index_books_on_open_library_id", unique: true
    t.index ["rating"], name: "index_books_on_rating"
    t.index ["series_id"], name: "index_books_on_series_id"
    t.index ["status"], name: "index_books_on_status"
  end

  create_table "series", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "books", "authors"
  add_foreign_key "books", "series"
end
