import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput", 
    "workPlaceSelect", 
    "workTypeSelect", 
    "experienceLevelSelect", 
    "salaryTypeSelect", 
    "dateRangeSelect",
    "card",
    "resultsContainer",
    "resultsCount",
    "noResults"
  ]

  connect() {
    this.debounceTimeout = null
    this.initializeFilters()
  }

  disconnect() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
  }

  initializeFilters() {
    // Set initial results count
    this.updateResultsCount()
    
    // Check if we have server-side filtered results
    const hasServerFilters = this.hasServerFilters()
    if (hasServerFilters) {
      // Disable client-side filtering when server filters are applied
      this.disableClientSideFiltering()
    }
  }

  hasServerFilters() {
    const urlParams = new URLSearchParams(window.location.search)
    return urlParams.has('search') || 
           urlParams.has('work_place') || 
           urlParams.has('work_type') || 
           urlParams.has('experience_level') || 
           urlParams.has('salary_type') || 
           urlParams.has('date_range')
  }

  disableClientSideFiltering() {
    // Remove client-side event listeners
    this.searchInputTarget.removeEventListener('input', this.debouncedSearch)
    this.workPlaceSelectTarget.removeEventListener('change', this.applyFilters)
    this.workTypeSelectTarget.removeEventListener('change', this.applyFilters)
    this.experienceLevelSelectTarget.removeEventListener('change', this.applyFilters)
    this.salaryTypeSelectTarget.removeEventListener('change', this.applyFilters)
    this.dateRangeSelectTarget.removeEventListener('change', this.applyFilters)
  }

  debouncedSearch(event) {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    this.debounceTimeout = setTimeout(() => {
      this.applyFilters()
    }, 300)
  }

  applyFilters(event) {
    // If this is triggered by a form submission, allow it to proceed
    if (event && event.type === 'submit') {
      return true
    }

    // Prevent form submission for client-side filtering
    if (event) {
      event.preventDefault()
    }

    const searchTerm = this.searchInputTarget.value.toLowerCase()
    const workPlace = this.workPlaceSelectTarget.value
    const workType = this.workTypeSelectTarget.value
    const experienceLevel = this.experienceLevelSelectTarget.value
    const salaryType = this.salaryTypeSelectTarget.value
    const dateRange = this.dateRangeSelectTarget.value

    let visibleCount = 0

    this.cardTargets.forEach(card => {
      let shouldShow = true

      // Search filter
      if (searchTerm) {
        const searchText = card.dataset.searchText
        if (!searchText.includes(searchTerm)) {
          shouldShow = false
        }
      }

      // Work place filter
      if (workPlace && card.dataset.workPlace !== workPlace) {
        shouldShow = false
      }

      // Work type filter
      if (workType && card.dataset.workType !== workType) {
        shouldShow = false
      }

      // Experience level filter
      if (experienceLevel && card.dataset.experienceLevel !== experienceLevel) {
        shouldShow = false
      }

      // Salary type filter
      if (salaryType && card.dataset.salaryType !== salaryType) {
        shouldShow = false
      }

      // Date range filter
      if (dateRange) {
        const createdDate = new Date(card.dataset.createdDate)
        const today = new Date()
        
        switch (dateRange) {
          case 'today':
            if (createdDate.toDateString() !== today.toDateString()) {
              shouldShow = false
            }
            break
          case 'week':
            const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000)
            if (createdDate < weekAgo) {
              shouldShow = false
            }
            break
          case 'month':
            const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000)
            if (createdDate < monthAgo) {
              shouldShow = false
            }
            break
          case '3months':
            const threeMonthsAgo = new Date(today.getTime() - 90 * 24 * 60 * 60 * 1000)
            if (createdDate < threeMonthsAgo) {
              shouldShow = false
            }
            break
          case '6months':
            const sixMonthsAgo = new Date(today.getTime() - 180 * 24 * 60 * 60 * 1000)
            if (createdDate < sixMonthsAgo) {
              shouldShow = false
            }
            break
          case 'year':
            const yearAgo = new Date(today.getTime() - 365 * 24 * 60 * 60 * 1000)
            if (createdDate < yearAgo) {
              shouldShow = false
            }
            break
        }
      }

      // Show/hide card
      if (shouldShow) {
        card.style.display = 'block'
        visibleCount++
      } else {
        card.style.display = 'none'
      }
    })

    // Update results count and show/hide no results message
    this.updateResultsCount(visibleCount)
    this.toggleNoResultsMessage(visibleCount)
  }

  clearFilters() {
    // Reset all form inputs
    this.searchInputTarget.value = ''
    this.workPlaceSelectTarget.value = ''
    this.workTypeSelectTarget.value = ''
    this.experienceLevelSelectTarget.value = ''
    this.salaryTypeSelectTarget.value = ''
    this.dateRangeSelectTarget.value = ''

    // Show all cards
    this.cardTargets.forEach(card => {
      card.style.display = 'block'
    })

    // Update results count
    this.updateResultsCount()
    this.toggleNoResultsMessage(this.cardTargets.length)

    // Submit the form to clear server-side filters
    this.element.submit()
  }

  updateResultsCount(visibleCount = null) {
    const count = visibleCount !== null ? visibleCount : this.cardTargets.length
    this.resultsCountTarget.textContent = `Showing ${count} results`
  }

  toggleNoResultsMessage(visibleCount) {
    if (visibleCount === 0) {
      this.noResultsTarget.classList.remove('hidden')
      this.resultsContainerTarget.classList.add('hidden')
    } else {
      this.noResultsTarget.classList.add('hidden')
      this.resultsContainerTarget.classList.remove('hidden')
    }
  }
} 