import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("Search filters controller connected")
  }

  apply() {
    // Auto-submit the form when any filter changes
    this.element.requestSubmit()
  }

  clear() {
    // Clear all filter values
    const selects = this.element.querySelectorAll('select')
    selects.forEach(select => {
      select.value = ''
    })
    
    // Submit the form to refresh results
    this.element.requestSubmit()
  }
} 