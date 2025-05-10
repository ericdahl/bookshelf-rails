class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.references :author, null: false, foreign_key: true
      t.references :series, null: false, foreign_key: true
      t.string :status
      t.string :open_library_id
      t.string :cover_url
      t.integer :user_rating
      t.text :user_comments
      t.string :media_type
      t.date :published_date
      t.string :isbn
      t.string :genre
      t.integer :page_count
      t.datetime :started_reading_at
      t.datetime :finished_reading_at

      t.timestamps
    end
  end
end
