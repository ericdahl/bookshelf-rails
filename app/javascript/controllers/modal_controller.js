import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  close() {
    const frame = this.element.closest("turbo-frame") || document.getElementById("book_modal")
    if (frame) {
      frame.removeAttribute("src")
      frame.innerHTML = ""
    }
    document.body.classList.remove("overflow-hidden")
  }
}
