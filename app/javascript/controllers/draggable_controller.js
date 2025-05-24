import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["book", "category"]
  static values = {
    bookId: String
  }

  dragstart(event) {
    event.dataTransfer.setData("text/plain", event.target.dataset.bookId)
    event.target.classList.add("opacity-50")
  }

  dragend(event) {
    event.target.classList.remove("opacity-50")
  }

  dragover(event) {
    event.preventDefault()
    event.currentTarget.classList.add("bg-blue-50")
  }

  dragleave(event) {
    event.currentTarget.classList.remove("bg-blue-50")
  }

  drop(event) {
    event.preventDefault()
    const bookId = event.dataTransfer.getData("text/plain")
    const newStatus = event.currentTarget.dataset.status
    
    console.log(`Moving book ${bookId} to status ${newStatus}`)
    
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token) {
      console.error("CSRF token not found")
      return
    }

    fetch(`/books/${bookId}/update_status`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ status: newStatus })
    }).then(response => {
      if (response.ok) {
        window.location.reload()
      } else {
        console.error("Failed to update book status:", response.statusText)
      }
    }).catch(error => {
      console.error("Error updating book status:", error)
    })
  }
} 