class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn_10
      t.string :isbn_13
      t.integer :publication_year
      t.string :publisher
      t.integer :page_count
      t.text :description
      t.string :cover_image_url
      t.string :open_library_id
      t.references :series, null: false, foreign_key: true
      t.string :status
      t.integer :rating
      t.text :comments
      t.string :book_type
      t.datetime :date_added
      t.datetime :date_started
      t.datetime :date_finished

      t.timestamps
    end
    add_index :books, :isbn_10, unique: true
    add_index :books, :isbn_13, unique: true
  end
end
