import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submitButton"]

  // This controller is mainly for UX enhancements
  // The form will submit normally via Turbo
} 