import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.setupFormHandling()
    this.setupKeyboardShortcuts()
    this.setupAutoSave()
    this.setupProgressTracking()
    this.updateProgress() // Initial progress calculation
  }

  setupFormHandling() {
    const form = this.element
    if (!form) return

    // Handle form submission
    form.addEventListener('submit', (e) => {
      this.handleSubmit(e)
    })

    // Setup field validation
    this.setupFieldValidation()
  }

  setupFieldValidation() {
    const requiredFields = this.element.querySelectorAll('[required]')
    requiredFields.forEach(field => {
      field.addEventListener('blur', () => {
        this.validateField(field)
      })
      
      field.addEventListener('input', () => {
        if (field.classList.contains('error')) {
          this.clearFieldError(field)
        }
      })
    })
  }

  validateField(field) {
    const value = field.value.trim()
    const isRequired = field.hasAttribute('required')
    
    if (isRequired && !value) {
      this.showFieldError(field, 'This field is required')
      return false
    }
    
    // Email validation
    if (field.type === 'email' && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(value)) {
        this.showFieldError(field, 'Please enter a valid email address')
        return false
      }
    }
    
    // Phone validation
    if (field.type === 'tel' && value) {
      const phoneRegex = /^(\+880|880)?1[3-9]\d{8}$/
      if (!phoneRegex.test(value.replace(/\s/g, ''))) {
        this.showFieldError(field, 'Please enter a valid Bangladeshi phone number')
        return false
      }
    }
    
    return true
  }

  showFieldError(field, message) {
    field.classList.add('error', 'border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    
    // Remove existing error message
    const existingError = field.parentElement.querySelector('.field-error')
    if (existingError) {
      existingError.remove()
    }
    
    // Add error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'field-error text-red-600 text-sm mt-1'
    errorDiv.textContent = message
    field.parentElement.appendChild(errorDiv)
  }

  clearFieldError(field) {
    field.classList.remove('error', 'border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.add('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
    
    const errorDiv = field.parentElement.querySelector('.field-error')
    if (errorDiv) {
      errorDiv.remove()
    }
  }

  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Ctrl/Cmd + S to save
      if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault()
        this.saveForm()
      }
      
      // Ctrl/Cmd + Enter to submit
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault()
        this.submitForm()
      }
    })
  }

  handleSubmit(e) {
    e.preventDefault()
    
    // Validate all fields
    const isValid = this.validateAllFields()
    if (!isValid) {
      this.showToast('Please fix the errors before submitting', 'error')
      return false
    }
    
    this.submitForm()
  }

  validateAllFields() {
    const requiredFields = this.element.querySelectorAll('[required]')
    let isValid = true
    
    requiredFields.forEach(field => {
      if (!this.validateField(field)) {
        isValid = false
      }
    })
    
    return isValid
  }

  saveForm() {
    const form = this.element
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showToast('Resume saved successfully!', 'success')
      } else {
        this.showToast('Failed to save resume', 'error')
      }
    })
    .catch(error => {
      console.error('Save failed:', error)
      this.showToast('Failed to save resume', 'error')
    })
  }

  submitForm() {
    // Find the submit button in the form
    const submitButton = this.element.querySelector('input[type="submit"], button[type="submit"]')
    if (submitButton) {
      submitButton.disabled = true
      const originalText = submitButton.innerHTML
      submitButton.innerHTML = `
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Saving...
      `
      
      // Re-enable button after a delay in case of errors
      setTimeout(() => {
        submitButton.disabled = false
        submitButton.innerHTML = originalText
      }, 5000)
    }
    
    this.element.submit()
  }

  showToast(message, type = 'info') {
    // Dispatch a custom event that the resume-preview controller can listen to
    const event = new CustomEvent('showToast', {
      detail: { message, type }
    })
    document.dispatchEvent(event)
  }

  // Public methods for external use
  addSection(sectionType) {
    // This can be called from other controllers
    const event = new CustomEvent('addSection', { detail: { type: sectionType } })
    this.element.dispatchEvent(event)
  }

  removeSection(sectionId) {
    // This can be called from other controllers
    const event = new CustomEvent('removeSection', { detail: { id: sectionId } })
    this.element.dispatchEvent(event)
  }

  setupAutoSave() {
    const form = this.element
    if (!form) return

    let saveTimeout
    const inputs = form.querySelectorAll('input, textarea, select')
    
    inputs.forEach(input => {
      input.addEventListener('change', () => {
        clearTimeout(saveTimeout)
        saveTimeout = setTimeout(() => {
          this.autoSave(form)
        }, 2000) // Save after 2 seconds of inactivity
      })
    })
  }

  autoSave(form) {
    const formData = new FormData(form)
    const url = form.action
    
    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showToast('Changes saved automatically', 'success')
      }
    })
    .catch(error => {
      console.error('Auto-save failed:', error)
      this.showToast('Failed to save changes', 'error')
    })
  }

  triggerPreview(event) {
    event.preventDefault()
    // Dispatch a custom event that the resume-preview controller can listen to
    const previewEvent = new CustomEvent('triggerPreview', {
      detail: { form: this.element }
    })
    document.dispatchEvent(previewEvent)
  }

  // Progress tracking methods
  setupProgressTracking() {
    const form = this.element
    if (!form) return

    // Listen for changes in all form fields
    const inputs = form.querySelectorAll('input, textarea, select')
    inputs.forEach(input => {
      input.addEventListener('input', () => {
        this.updateProgress()
      })
      
      input.addEventListener('change', () => {
        this.updateProgress()
      })
    })

    // Listen for nested form changes
    form.addEventListener('nestedFormAdded', () => {
      this.updateProgress()
    })

    form.addEventListener('nestedFormRemoved', () => {
      this.updateProgress()
    })
  }

  updateProgress() {
    const progress = this.calculateProgress()
    this.updateProgressBar(progress)
    this.updateProgressText(progress)
  }

  calculateProgress() {
    const form = this.element
    if (!form) return 0

    let totalFields = 0
    let completedFields = 0

    // Basic information section
    const basicFields = [
      'user[first_name]',
      'user[last_name]',
      'user[email]',
      'user[phone]',
      'user[career_objective]'
    ]

    basicFields.forEach(fieldName => {
      totalFields++
      const field = form.querySelector(`[name="${fieldName}"]`)
      if (field && field.value.trim()) {
        completedFields++
      }
    })

    // Education section - check both existing and new entries
    const educationFields = form.querySelectorAll('[name*="user_educations_attributes"][name*="degree"], [name*="user_educations_attributes"][name*="institution_name"]')
    if (educationFields.length > 0) {
      totalFields += 2 // degree and institution are required
      const hasEducation = Array.from(educationFields).some(field => field.value.trim())
      if (hasEducation) {
        completedFields += 2
      }
    } else {
      totalFields += 2
    }

    // Work experience section - check both existing and new entries
    const workFields = form.querySelectorAll('[name*="user_work_experiences_attributes"][name*="designation"], [name*="user_work_experiences_attributes"][name*="company_name"]')
    if (workFields.length > 0) {
      totalFields += 2 // designation and company are required
      const hasWork = Array.from(workFields).some(field => field.value.trim())
      if (hasWork) {
        completedFields += 2
      }
    } else {
      totalFields += 2
    }

    // Skills section - check both existing and new entries
    const skillFields = form.querySelectorAll('[name*="user_skills_attributes"][name*="skill_name"]')
    if (skillFields.length > 0) {
      totalFields += 1
      const hasSkills = Array.from(skillFields).some(field => field.value.trim())
      if (hasSkills) {
        completedFields += 1
      }
    } else {
      totalFields += 1
    }

    // Accomplishments section - check both existing and new entries
    const accomplishmentFields = form.querySelectorAll('[name*="user_accomplishments_attributes"][name*="accomplishment_name"]')
    if (accomplishmentFields.length > 0) {
      totalFields += 1
      const hasAccomplishments = Array.from(accomplishmentFields).some(field => field.value.trim())
      if (hasAccomplishments) {
        completedFields += 1
      }
    } else {
      totalFields += 1
    }

    return totalFields > 0 ? Math.round((completedFields / totalFields) * 100) : 0
  }

  updateProgressBar(progress) {
    const progressBar = document.querySelector('[data-progress-bar]')
    if (progressBar) {
      const progressFill = progressBar.querySelector('[data-progress-fill]')
      if (progressFill) {
        progressFill.style.width = `${progress}%`
        
        // Update color based on progress
        progressFill.className = progressFill.className.replace(/bg-\w+-500/g, '')
        if (progress < 25) {
          progressFill.classList.add('bg-red-500')
        } else if (progress < 50) {
          progressFill.classList.add('bg-orange-500')
        } else if (progress < 75) {
          progressFill.classList.add('bg-yellow-500')
        } else {
          progressFill.classList.add('bg-green-500')
        }
      }
    }
  }

  updateProgressText(progress) {
    const progressText = document.querySelector('[data-progress-text]')
    if (progressText) {
      progressText.textContent = `${progress}% Complete`
    }
  }
} 