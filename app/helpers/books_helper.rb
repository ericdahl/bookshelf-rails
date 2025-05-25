module BooksHelper
  def status_title(status)
    {
      "want_to_read" => "Want to Read",
      "currently_reading" => "Currently Reading",
      "read" => "Read"
    }[status]
  end
end
