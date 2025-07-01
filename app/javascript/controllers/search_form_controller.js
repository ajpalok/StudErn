import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Initialize the search form
    console.log("Search form controller connected")
    this.debounceTimer = null
  }

  search() {
    const query = this.inputTarget.value.trim()
    
    // Clear previous timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
    
    // Set new timer for debouncing
    this.debounceTimer = setTimeout(() => {
      if (query.length >= 2) {
        // Update URL with search query and preserve existing filters
        const url = new URL(window.location)
        url.searchParams.set('q', query)
        
        // Preserve existing filter parameters
        const currentFilters = ['work_place', 'work_type', 'recruitment_type', 'experience_level', 'date_range', 'salary_type', 'user_experience_level']
        currentFilters.forEach(filter => {
          const value = url.searchParams.get(filter)
          if (value) {
            url.searchParams.set(filter, value)
          }
        })
        
        window.history.pushState({}, '', url)
        
        // Submit the form to get results
        this.element.requestSubmit()
      } else if (query.length === 0) {
        // Clear search results when query is empty but preserve filters
        const url = new URL(window.location)
        url.searchParams.delete('q')
        
        // Keep filter parameters
        const currentFilters = ['work_place', 'work_type', 'recruitment_type', 'experience_level', 'date_range', 'salary_type', 'user_experience_level']
        const hasFilters = currentFilters.some(filter => url.searchParams.has(filter))
        
        if (hasFilters) {
          // If filters are applied, just remove the query
          window.history.pushState({}, '', url)
          this.element.requestSubmit()
        } else {
          // If no filters, reload page to show empty state
          window.location.reload()
        }
      }
    }, 500) // 500ms debounce
  }

  // Handle form submission
  submit(event) {
    const query = this.inputTarget.value.trim()
    
    if (query.length < 2) {
      event.preventDefault()
      return false
    }
  }
} 