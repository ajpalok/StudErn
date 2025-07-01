import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "educationList", "skillList", "workList", "accomplishmentList"
  ]

  connect() {
    // console.log("Nested form controller connected")
  }

  addEducation(event) {
    event.preventDefault()
    this.addNestedItem("educationList", "user_educations", "education")
  }

  addSkill(event) {
    event.preventDefault()
    this.addNestedItem("skillList", "user_skills", "skill")
  }

  addWork(event) {
    event.preventDefault()
    this.addNestedItem("workList", "user_work_experiences", "work")
  }

  addAccomplishment(event) {
    event.preventDefault()
    this.addNestedItem("accomplishmentList", "user_accomplishments", "accomplishment")
  }

  addNestedItem(listTargetName, associationName, partialName) {
    const listTarget = this[listTargetName + "Target"]
    
    if (!listTarget) {
      console.error(`Target not found: ${listTargetName}`)
      return
    }

    const time = new Date().getTime()
    const newId = `new_${time}`
    
    // Create a temporary form field to get the proper Rails form structure
    const tempForm = document.createElement('form')
    tempForm.innerHTML = this.getTemplateHTML(associationName, newId, partialName)
    
    const newItem = tempForm.firstElementChild
    
    if (!newItem) {
      console.error("No content found in template")
      return
    }

    // Add animation classes
    newItem.style.opacity = '0'
    newItem.style.transform = 'translateY(-10px)'
    
    // Append to the list
    listTarget.appendChild(newItem)
    
    // Animate in
    requestAnimationFrame(() => {
      newItem.style.transition = 'all 0.3s ease-out'
      newItem.style.opacity = '1'
      newItem.style.transform = 'translateY(0)'
    })
    
    // Scroll to new item
    setTimeout(() => {
      newItem.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }, 100)
    
    // Dispatch event for progress tracking
    const customEvent = new CustomEvent('nestedFormAdded', {
      detail: { type: associationName, id: newId }
    })
    this.element.dispatchEvent(customEvent)
    
    // console.log(`Added new ${associationName} item with ID: ${newId}`)
  }

  getTemplateHTML(associationName, newId, partialName) {
    const templates = {
      user_educations: `
        <div class="nested-fields relative bg-gray-50 rounded-lg p-6 mb-4 border border-gray-200 hover:border-gray-300 transition-colors">
          <!-- Remove Button -->
          <button type="button" class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors" data-action="click->nested-form#removeItem">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>

          <!-- Education Icon -->
          <div class="flex items-center mb-4">
            <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center mr-3">
              <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"></path>
              </svg>
            </div>
            <h4 class="text-lg font-medium text-gray-900">Education Entry</h4>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Degree/Certificate</label>
              <input type="text" name="user[user_educations_attributes][${newId}][degree]" placeholder="e.g., Bachelor of Science in Computer Science" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Institution</label>
              <input type="text" name="user[user_educations_attributes][${newId}][institution_name]" placeholder="e.g., United International University" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
              <input type="date" name="user[user_educations_attributes][${newId}][start_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">End Date</label>
              <input type="date" name="user[user_educations_attributes][${newId}][end_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Performance Type</label>
              <select name="user[user_educations_attributes][${newId}][performance_type]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
                <option value="">Select performance type</option>
                <option value="percentage">Percentage</option>
                <option value="cgpa_out_of_4">CGPA (out of 4)</option>
                <option value="cgpa_out_of_5">CGPA (out of 5)</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Performance</label>
              <input type="number" step="0.01" name="user[user_educations_attributes][${newId}][performance]" placeholder="e.g., 3.75" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors">
            </div>
          </div>

          <div class="mt-4">
            <label class="flex items-center">
              <input type="checkbox" name="user[user_educations_attributes][${newId}][currently_studying]" value="1" class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded">
              <span class="ml-2 text-sm text-gray-700">Currently studying here</span>
            </label>
          </div>

          <input type="hidden" name="user[user_educations_attributes][${newId}][_destroy]" value="0">
        </div>
      `,
      user_skills: `
        <div class="nested-fields relative bg-gray-50 rounded-lg p-6 mb-4 border border-gray-200 hover:border-gray-300 transition-colors">
          <!-- Remove Button -->
          <button type="button" class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors" data-action="click->nested-form#removeItem">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>

          <!-- Skill Icon -->
          <div class="flex items-center mb-4">
            <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center mr-3">
              <svg class="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
              </svg>
            </div>
            <h4 class="text-lg font-medium text-gray-900">Skill Entry</h4>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Skill Name</label>
              <input type="text" name="user[user_skills_attributes][${newId}][skill_name]" placeholder="e.g., JavaScript, Project Management" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Skill Level</label>
              <select name="user[user_skills_attributes][${newId}][skill_level]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-colors">
                <option value="">Select skill level</option>
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
                <option value="expert">Expert</option>
              </select>
            </div>
          </div>

          <input type="hidden" name="user[user_skills_attributes][${newId}][_destroy]" value="0">
        </div>
      `,
      user_work_experiences: `
        <div class="nested-fields relative bg-gray-50 rounded-lg p-6 mb-4 border border-gray-200 hover:border-gray-300 transition-colors">
          <!-- Remove Button -->
          <button type="button" class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors" data-action="click->nested-form#removeItem">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>

          <!-- Work Icon -->
          <div class="flex items-center mb-4">
            <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center mr-3">
              <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2-2v2m8 0V6a2 2 0 012 2v6a2 2 0 01-2 2H8a2 2 0 01-2-2V8a2 2 0 012-2V6"></path>
              </svg>
            </div>
            <h4 class="text-lg font-medium text-gray-900">Work Experience Entry</h4>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Job Title</label>
              <input type="text" name="user[user_work_experiences_attributes][${newId}][designation]" placeholder="e.g., Senior Software Engineer" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Company</label>
              <input type="text" name="user[user_work_experiences_attributes][${newId}][company_name]" placeholder="e.g., Tech Solutions Inc." class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
              <input type="date" name="user[user_work_experiences_attributes][${newId}][start_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">End Date</label>
              <input type="date" name="user[user_work_experiences_attributes][${newId}][end_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors">
            </div>
          </div>

          <div class="mt-4">
            <label class="flex items-center">
              <input type="checkbox" name="user[user_work_experiences_attributes][${newId}][currently_working]" value="1" class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
              <span class="ml-2 text-sm text-gray-700">Currently working here</span>
            </label>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Employment Type</label>
            <select name="user[user_work_experiences_attributes][${newId}][employment_type]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors">
              <option value="">Select employment type</option>
              <option value="full_time">Full-time</option>
              <option value="part_time">Part-time</option>
              <option value="project">Project</option>
              <option value="freelance">Freelance</option>
            </select>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Job Description & Responsibilities</label>
            <textarea name="user[user_work_experiences_attributes][${newId}][job_responsibilities]" placeholder="Describe your role, responsibilities, and key achievements..." rows="4" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors resize-none"></textarea>
            <p class="mt-1 text-xs text-gray-500">Use bullet points to highlight key achievements and responsibilities</p>
          </div>

          <input type="hidden" name="user[user_work_experiences_attributes][${newId}][_destroy]" value="0">
        </div>
      `,
      user_accomplishments: `
        <div class="nested-fields relative bg-gray-50 rounded-lg p-6 mb-4 border border-gray-200 hover:border-gray-300 transition-colors">
          <!-- Remove Button -->
          <button type="button" class="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors" data-action="click->nested-form#removeItem">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>

          <!-- Accomplishment Icon -->
          <div class="flex items-center mb-4">
            <div class="w-8 h-8 bg-yellow-100 rounded-lg flex items-center justify-center mr-3">
              <svg class="w-4 h-4 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"></path>
              </svg>
            </div>
            <h4 class="text-lg font-medium text-gray-900">Accomplishment Entry</h4>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Accomplishment Type</label>
              <select name="user[user_accomplishments_attributes][${newId}][accomplishment_type]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors">
                <option value="">Select accomplishment type</option>
                <option value="project">Project</option>
                <option value="portfolio">Portfolio</option>
                <option value="publication">Publication</option>
                <option value="certification">Certification</option>
                <option value="award">Award</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">URL (Optional)</label>
              <input type="url" name="user[user_accomplishments_attributes][${newId}][accomplishment_url]" placeholder="https://example.com/project" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors">
            </div>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Accomplishment Name</label>
            <input type="text" name="user[user_accomplishments_attributes][${newId}][accomplishment_name]" placeholder="e.g., Best Developer Award 2023" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors">
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
              <input type="date" name="user[user_accomplishments_attributes][${newId}][accomplishment_start_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">End Date</label>
              <input type="date" name="user[user_accomplishments_attributes][${newId}][accomplishment_end_date]" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors">
            </div>
          </div>

          <div class="mt-4">
            <label class="flex items-center">
              <input type="checkbox" name="user[user_accomplishments_attributes][${newId}][ongoing]" value="1" class="h-4 w-4 text-yellow-600 focus:ring-yellow-500 border-gray-300 rounded">
              <span class="ml-2 text-sm text-gray-700">Ongoing accomplishment</span>
            </label>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea name="user[user_accomplishments_attributes][${newId}][accomplishment_description]" placeholder="Describe your accomplishment, the impact it had, and any relevant details..." rows="4" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500 transition-colors resize-none"></textarea>
            <p class="mt-1 text-xs text-gray-500">Use bullet points to highlight key achievements and impact</p>
          </div>

          <input type="hidden" name="user[user_accomplishments_attributes][${newId}][_destroy]" value="0">
        </div>
      `
    }

    return templates[associationName] || ''
  }

  removeItem(event) {
    event.preventDefault()
    const item = event.target.closest('.nested-fields')
    if (!item) return

    const destroyInput = item.querySelector('input[type="hidden"][name*="_destroy"]')
    
    if (destroyInput) {
      // Mark for destruction
      destroyInput.value = 1
      
      // Animate out
      item.style.transition = 'all 0.3s ease-in'
      item.style.opacity = '0'
      item.style.transform = 'translateY(-10px)'
      
      setTimeout(() => {
        item.style.display = 'none'
      }, 300)
    } else {
      // Remove immediately if no destroy field
      item.style.transition = 'all 0.3s ease-in'
      item.style.opacity = '0'
      item.style.transform = 'translateY(-10px)'
      
      setTimeout(() => {
        item.remove()
      }, 300)
    }
    
    // Dispatch event for progress tracking
    const customEvent = new CustomEvent('nestedFormRemoved', {
      detail: { element: item }
    })
    this.element.dispatchEvent(customEvent)
  }

  // For backwards compatibility with per-section remove buttons
  removeEducation(event) { this.removeItem(event) }
  removeSkill(event) { this.removeItem(event) }
  removeWork(event) { this.removeItem(event) }
  removeAccomplishment(event) { this.removeItem(event) }
} 