class AddDbConstraintsAndIndexesToBooks < ActiveRecord::Migration[8.0]
  def up
    # Backfill any nulls before adding NOT NULL constraints so existing
    # rows do not violate the constraint on databases that enforce it eagerly.
    Book.where(title: nil).update_all(title: "Unknown Title")
    Book.where(status: nil).update_all(status: "want_to_read")
    Book.where(book_type: nil).update_all(book_type: "physical_book")

    change_column_null :books, :title, false
    change_column_null :books, :status, false
    change_column_null :books, :book_type, false

    add_index :books, :status
    add_index :books, :open_library_id
  end

  def down
    remove_index :books, :open_library_id
    remove_index :books, :status

    change_column_null :books, :title, true
    change_column_null :books, :status, true
    change_column_null :books, :book_type, true
  end
end
