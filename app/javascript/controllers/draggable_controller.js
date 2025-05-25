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
    event.currentTarget.classList.remove("bg-blue-50")
    
    const bookId = event.dataTransfer.getData("text/plain")
    const newStatus = event.currentTarget.dataset.status
    
    console.log(`Moving book ${bookId} to status ${newStatus}`)
    
    // Use Turbo to submit the form
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = `/books/${bookId}/update_status`
    form.style.display = 'none'
    
    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }
    
    // Add method override for PATCH
    const methodInput = document.createElement('input')
    methodInput.type = 'hidden'
    methodInput.name = '_method'
    methodInput.value = 'PATCH'
    form.appendChild(methodInput)
    
    // Add status parameter
    const statusInput = document.createElement('input')
    statusInput.type = 'hidden'
    statusInput.name = 'status'
    statusInput.value = newStatus
    form.appendChild(statusInput)
    
    // Submit with Turbo
    document.body.appendChild(form)
    form.requestSubmit()
    document.body.removeChild(form)
  }
} 