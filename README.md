# Bookshelf

A personal book tracking app built with Rails 8.1. Track books you want to read,
are currently reading, or have finished. Search the OpenLibrary catalogue and add
books directly to your shelf.

## Tech stack

- **Ruby** 3.4.4 / **Rails** 8.1
- **SQLite** (development, test, production)
- **Tailwind CSS** + **Hotwire** (Turbo + Stimulus)
- **HTTParty** for OpenLibrary API calls
- **Minitest** + **WebMock** for tests

---

## Prerequisites

| Tool | Notes |
|------|-------|
| Ruby 3.4.4 | Use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/) |
| Bundler 2.6.9 | `gem install bundler -v 2.6.9` |
| SQLite 3 | Usually pre-installed on macOS/Linux |
| Node.js | Only needed if you change JS assets |

---

## Getting started

```bash
# 1. Clone and enter the repo
git clone <repo-url>
cd bookshelf-rails

# 2. Install the exact Bundler version pinned in Gemfile.lock
gem install bundler -v 2.6.9

# 3. Install gems (vendored locally — no system-wide install needed)
bundle _2.6.9_ install

# 4. Set up the database
bundle _2.6.9_ exec rails db:create db:migrate db:seed

# 5. Start the server
bundle _2.6.9_ exec rails server
```

Open http://localhost:3000 — you should see the bookshelf index.

---

## Running the tests

```bash
# Run the full test suite
bundle _2.6.9_ exec rails test

# Run a single file
bundle _2.6.9_ exec rails test test/controllers/books_controller_test.rb

# Run a single test by line number
bundle _2.6.9_ exec rails test test/models/book_test.rb:42
```

Expected output (all green):

```
106 runs, 252 assertions, 0 failures, 0 errors, 0 skips
```

Tests use **WebMock** to block real network calls — no internet access is
required and no calls are made to OpenLibrary during the test run.

---

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `API_TOKEN` | Optional | Token required by `X-Api-Token` header to use the `/api/v1/books` REST API. If unset the API returns 401 for every request. |

Set it in `.env` (loaded automatically via the `dotenv` gem in development):

```bash
# .env  — never commit this file
API_TOKEN=your-secret-token
```

---

## Project structure

```
app/
  controllers/
    books_controller.rb          # Main UI controller
    series_controller.rb         # Series CRUD
    api/v1/
      books_controller.rb        # REST API (token-authenticated)
      open_library_searches_controller.rb  # Proxies OpenLibrary search
  models/
    book.rb                      # Book model (status/book_type enums, validations)
    series.rb                    # Series model
  services/
    open_library_search_service.rb  # Wraps OpenLibrary HTTP search
  views/books/                   # Turbo Stream partials for live updates
test/
  controllers/                   # Integration tests
  models/                        # Unit tests
```

## Key features

- **Three statuses**: Want to Read → Currently Reading → Read
- **Three book types**: Physical, eBook, Audiobook
- **Ratings**: 1–10 (optional)
- **Series tracking**: books can belong to a series
- **Undo delete**: last-deleted book can be restored within the session
- **OpenLibrary search**: add books by title/author without manual data entry
- **REST API**: full CRUD at `/api/v1/books` (requires `X-Api-Token` header)
