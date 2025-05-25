import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    const url = new URL(form.action)
    
    // Add form data to URL as query parameters
    for (const [key, value] of formData.entries()) {
      url.searchParams.set(key, value)
    }
    
    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Parse and execute the turbo stream response
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, 'text/html')
      const turboStream = doc.querySelector('turbo-stream')
      
      if (turboStream) {
        const target = turboStream.getAttribute('target')
        const action = turboStream.getAttribute('action')
        const template = turboStream.querySelector('template')
        
        if (action === 'replace' && target && template) {
          const targetElement = document.getElementById(target)
          if (targetElement) {
            targetElement.innerHTML = template.innerHTML
          }
        }
      }
    })
    .catch(error => {
      console.error('Search error:', error)
    })
  }
} 