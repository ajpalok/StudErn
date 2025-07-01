import { Controller } from "@hotwired/stimulus"

function humanizePerformanceType(value) {
  if (!value) return ""
  // Replace underscores with spaces, then capitalize each word
  return value
    .replace(/_/g, " ")
    .replace(/\b\w/g, char => char.toUpperCase())
}

function humanizeSkillLevel(value) {
  if (!value) return ""
  // Map enum values to human-readable text
  const skillLevels = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate', 
    'advanced': 'Advanced',
    'expert': 'Expert'
  }
  return skillLevels[value] || value
}

function humanizeEmploymentType(value) {
  if (!value) return ""
  // Map enum values to human-readable text
  const employmentTypes = {
    'full_time': 'Full-time',
    'part_time': 'Part-time',
    'project': 'Project',
    'freelance': 'Freelance'
  }
  return employmentTypes[value] || value
}

function humanizeAccomplishmentType(value) {
  if (!value) return ""
  // Map enum values to human-readable text
  const accomplishmentTypes = {
    'project': 'Project',
    'portfolio': 'Portfolio',
    'publication': 'Publication',
    'certification': 'Certification',
    'award': 'Award',
    'other': 'Other'
  }
  return accomplishmentTypes[value] || value
}

export default class extends Controller {
  static targets = ["modal", "content", "toast"]

  connect() {
    // console.log("ResumePreviewController connected")
    // Listen for toast events from other controllers
    document.addEventListener('showToast', (e) => {
      this.showToast(e.detail.message, e.detail.type)
    })
    
    // Listen for preview trigger events
    document.addEventListener('triggerPreview', (e) => {
      this.previewResume(e.detail.form)
    })
  }

  previewResume(form = null) {
    // If no form is provided, try to find it
    if (!form) {
      form = this.element.querySelector('form')
    }
    
    if (!form) {
      console.error('No form found for preview')
      return
    }
    
    const formData = new FormData(form)
    
    // Show loading state
    this.contentTarget.innerHTML = `
      <div class="flex items-center justify-center h-32">
        <svg class="animate-spin h-8 w-8 text-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span class="ml-2 text-gray-600">Generating preview...</span>
      </div>
    `
    
    this.modalTarget.classList.remove('hidden')
    
    // Generate preview from form data
    const preview = this.generateResumePreview(formData)
    this.contentTarget.innerHTML = preview
  }

  closePreview() {
    this.modalTarget.classList.add('hidden')
  }

  printResume() {
    const printWindow = window.open('', '_blank')
    const firstName = this.element.querySelector('input[name="user[first_name]"]')?.value || 'User'
    
    // Get the form data for printing
    const form = this.element.querySelector('form')
    let printContent = ''
    
    if (form) {
      const formData = new FormData(form)
      printContent = this.generateResumePreview(formData)
    } else {
      // Fallback to current preview content
      printContent = this.contentTarget.innerHTML
    }
    
    printWindow.document.write(`
      <html>
        <head>
          <title>Resume - ${firstName}</title>
          <style>
            /* A4 Paper Settings */
            @page {
              size: A4;
              margin: 20mm 15mm;
            }
            
            body { 
              font-family: Arial, sans-serif; 
              margin: 0;
              padding: 0;
              line-height: 1.6;
              color: #333;
              font-size: 12pt;
            }
            
            .resume-preview .header { 
              text-align: center; 
              margin-bottom: 30px; 
              border-bottom: 2px solid #333;
              padding-bottom: 20px;
              page-break-after: avoid;
            }
            
            .resume-preview .header h1 {
              font-size: 24pt;
              font-weight: bold;
              margin-bottom: 10px;
              color: #1f2937;
            }
            
            .resume-preview .header p {
              font-size: 14pt;
              color: #6b7280;
              margin: 5px 0;
            }
            
            .resume-preview .career-objective-section {
              margin: 30px 0;
              font-weight: regular;
              page-break-inside: avoid;
              page-break-before: auto;
            }
            
            .resume-preview .career-objective-content {
              background-color: #f8fafc;
              border-left: 4px solid #3b82f6;
              padding: 15px 20px;
              border-radius: 0 8px 8px 0;
            }
            
            .resume-preview .career-objective-content p {
              margin: 0;
              font-size: 12pt;
              line-height: 1.6;
              color: #374151;
              font-style: normal;
              font-weight: normal;
            }
            
            .resume-preview .section { 
              margin-bottom: 25px; 
              page-break-inside: avoid;
              page-break-before: auto;
            }
            
            .resume-preview .section-title { 
              font-size: 16pt; 
              font-weight: bold; 
              margin-bottom: 15px; 
              border-bottom: 1px solid #d1d5db;
              padding-bottom: 5px;
              color: #1f2937;
              page-break-after: avoid;
            }
            
            .resume-preview .item { 
              margin-bottom: 20px; 
              padding-left: 10px;
              page-break-inside: avoid;
              page-break-before: auto;
            }
            
            .resume-preview .item-title { 
              font-weight: bold; 
              font-size: 14pt;
              color: #1f2937;
              margin-bottom: 5px;
            }
            
            .resume-preview .item-subtitle { 
              color: #6b7280; 
              font-style: italic;
              font-size: 12pt;
              margin-bottom: 3px;
            }
            
            .resume-preview .item-date { 
              color: #9ca3af; 
              font-size: 11pt; 
              margin-bottom: 8px;
            }
            
            .resume-preview .item-description { 
              margin-top: 8px; 
              font-size: 11pt;
              line-height: 1.5;
              color: #4b5563;
            }
            
            .resume-preview .skills-container {
              display: flex;
              flex-wrap: wrap;
              gap: 8px;
              margin-top: 10px;
              page-break-inside: avoid;
            }
            
            .resume-preview .skill-tag {
              background-color: #dbeafe;
              color: #1e40af;
              padding: 4px 12px;
              border-radius: 20px;
              font-size: 10pt;
              font-weight: 500;
              margin-bottom: 4px;
            }
            
            /* Two Column Layout */
            .resume-preview .two-column-section {
              display: flex;
              gap: 40px;
              margin-bottom: 25px;
              page-break-inside: avoid;
            }
            
            .resume-preview .column {
              flex: 1;
              min-width: 0;
            }
            
            .resume-preview .education-column {
              page-break-inside: avoid;
            }
            
            .resume-preview .work-column {
              page-break-inside: avoid;
            }
            
            /* Print-specific styles */
            @media print { 
              body { 
                margin: 0; 
                padding: 0;
              }
              
              .resume-preview .section { 
                page-break-inside: avoid; 
                orphans: 3;
                widows: 3;
              }
              
              .resume-preview .item { 
                page-break-inside: avoid;
                orphans: 2;
                widows: 2;
              }
              
              .resume-preview .skills-container {
                page-break-inside: avoid;
              }
              
              /* Ensure sections don't break at the top of a page */
              .resume-preview .section:first-child {
                page-break-before: auto;
              }
              
              /* Prevent orphaned section titles */
              .resume-preview .section-title {
                page-break-after: avoid;
              }
              
              /* Ensure items don't break across pages */
              .resume-preview .item {
                page-break-inside: avoid;
                break-inside: avoid;
              }
              
              /* Ensure header doesn't break */
              .resume-preview .header {
                page-break-after: avoid;
              }
              
              /* Career objective print styles */
              .resume-preview .career-objective-section {
                page-break-inside: avoid;
                break-inside: avoid;
              }
              
              .resume-preview .career-objective-content {
                background-color: #f8fafc !important;
                border-left: 4px solid #3b82f6 !important;
              }
              
              /* Two column print styles */
              .resume-preview .two-column-section {
                display: flex !important;
                gap: 40px !important;
                page-break-inside: avoid;
                break-inside: avoid;
              }
              
              .resume-preview .column {
                flex: 1 !important;
                min-width: 0 !important;
                page-break-inside: avoid;
                break-inside: avoid;
              }
            }
          </style>
        </head>
        <body>
          ${printContent}
        </body>
      </html>
    `)
    printWindow.document.close()
    printWindow.print()
  }

  generateResumePreview(formData) {
    // Extract data from form
    const firstName = formData.get('user[first_name]') || ''
    const lastName = formData.get('user[last_name]') || ''
    const email = formData.get('user[email]') || ''
    const phone = formData.get('user[phone]') || ''
    const careerObjective = formData.get('user[career_objective]') || ''
    
    let preview = `
      <div class="resume-preview">
        <div class="header">
          <h1>${firstName} ${lastName}</h1>
          <p>${email} | ${phone}</p>
        </div>
        ${careerObjective ? `
          <div class="career-objective-section">
            <div class="career-objective-content">
              <p>${careerObjective}</p>
            </div>
          </div>
        ` : ''}
    `
    
    // Education and Work Experience in 2 columns
    const educationEntries = this.parseNestedAttributes(formData, 'user_educations_attributes')
    const workEntries = this.parseNestedAttributes(formData, 'user_work_experiences_attributes')
    
    if (educationEntries.length > 0 || workEntries.length > 0) {
      preview += `<div class="two-column-section">`
      
      // Education column
      if (educationEntries.length > 0) {
        preview += `<div class="column education-column">`
        preview += `<h2 class="section-title">Education</h2>`
        educationEntries.forEach((edu, index) => {
          if (edu.degree || edu.institution_name) {
            const startDate = edu.start_date ? new Date(edu.start_date).getFullYear() : ''
            const endDate = edu.end_date ? new Date(edu.end_date).getFullYear() : ''
            const dateRange = startDate && endDate ? `${startDate} - ${endDate}` : 
                             startDate ? `${startDate} - Present` : ''
            
            preview += `
              <div class="item education-item" data-item-index="${index}">
                <div class="item-title">${edu.degree || ''}</div>
                <div class="item-subtitle">${edu.institution_name || ''}</div>
                ${dateRange ? `<div class="item-date">${dateRange}</div>` : ''}
                ${edu.performance ? `<div class="item-description">${edu.performance_type || ''}: ${edu.performance}</div>` : ''}
              </div>
            `
          }
        })
        preview += `</div>`
      }
      
      // Work Experience column
      if (workEntries.length > 0) {
        preview += `<div class="column work-column">`
        preview += `<h2 class="section-title">Work Experience</h2>`
        workEntries.forEach((work, index) => {
          if (work.designation || work.company_name) {
            const startDate = work.start_date ? new Date(work.start_date).getFullYear() : ''
            const endDate = work.end_date ? new Date(work.end_date).getFullYear() : ''
            const dateRange = startDate && endDate ? `${startDate} - ${endDate}` : 
                             startDate ? `${startDate} - Present` : ''
            
            preview += `
              <div class="item work-item" data-item-index="${index}">
                <div class="item-title">${work.designation || ''}</div>
                <div class="item-subtitle">${work.company_name || ''}</div>
                ${dateRange ? `<div class="item-date">${dateRange}</div>` : ''}
                ${work.employment_type ? `<div class="item-subtitle">${humanizeEmploymentType(work.employment_type)}</div>` : ''}
                ${work.job_responsibilities ? `<div class="item-description">${work.job_responsibilities}</div>` : ''}
              </div>
            `
          }
        })
        preview += `</div>`
      }
      
      preview += `</div>`
    }
    
    // Skills section - improved parsing
    const skillEntries = this.parseNestedAttributes(formData, 'user_skills_attributes')
    
    if (skillEntries.length > 0) {
      preview += `<div class="section skills-section"><h2 class="section-title">Skills</h2>`
      preview += `<div class="skills-container">`
      skillEntries.forEach((skill, index) => {
        if (skill.skill_name) {
          preview += `<span class="skill-tag" data-skill-index="${index}">${skill.skill_name}${skill.skill_level ? ` (${humanizeSkillLevel(skill.skill_level)})` : ''}</span>`
        }
      })
      preview += `</div></div>`
    }
    
    // Accomplishments section - improved parsing
    const accomplishmentEntries = this.parseNestedAttributes(formData, 'user_accomplishments_attributes')
    
    if (accomplishmentEntries.length > 0) {
      preview += `<div class="section accomplishments-section"><h2 class="section-title">Accomplishments</h2>`
      accomplishmentEntries.forEach((acc, index) => {
        if (acc.accomplishment_name) {
          const startDate = acc.accomplishment_start_date ? new Date(acc.accomplishment_start_date).getFullYear() : ''
          const endDate = acc.accomplishment_end_date ? new Date(acc.accomplishment_end_date).getFullYear() : ''
          const dateRange = startDate && endDate ? `${startDate} - ${endDate}` : 
                           startDate ? `${startDate} - Present` : ''
          
          preview += `
            <div class="item accomplishment-item" data-item-index="${index}">
              <div class="item-title">${acc.accomplishment_name}</div>
              ${acc.accomplishment_type ? `<div class="item-subtitle">${humanizeAccomplishmentType(acc.accomplishment_type)}</div>` : ''}
              ${acc.accomplishment_description ? `<div class="item-description">${acc.accomplishment_description}</div>` : ''}
              ${dateRange ? `<div class="item-date">${dateRange}</div>` : ''}
            </div>
          `
        }
      })
      preview += `</div>`
    }
    
    preview += `</div>`
    return preview
  }

  // Helper method to parse nested attributes from FormData
  parseNestedAttributes(formData, attributeName) {
    const entries = []
    const entryMap = new Map()
    
    // Iterate through all form data entries
    for (let [key, value] of formData.entries()) {
      // Skip destroy fields
      if (key.includes('_destroy')) continue
      
      // Match the pattern: user[attributeName][index][field]
      // This handles both existing records (numeric IDs) and new records (new_ prefixed IDs)
      const regex = new RegExp(`user\\[${attributeName.replace(/\[/g, '\\[').replace(/\]/g, '\\]')}\\]\\[([^\\]]+)\\]\\[(\\w+)\\]`)
      const match = key.match(regex)
      
      if (match) {
        const index = match[1]
        const field = match[2]
        
        if (!entryMap.has(index)) {
          entryMap.set(index, {})
        }
        
        const entry = entryMap.get(index)
        entry[field] = value
      }
    }
    
    // Convert map to array and filter out empty entries
    for (let [index, entry] of entryMap) {
      // Check if entry has meaningful data (not just empty strings)
      const hasData = Object.values(entry).some(value => value && value.toString().trim() !== '')
      if (hasData) {
        entries.push(entry)
      }
    }
    
    return entries
  }

  showToast(message, type = 'success') {
    if (this.hasToastTarget) {
      const toastContent = this.toastTarget.querySelector('div')
      const iconClass = type === 'success' ? 'text-green-400' : 
                       type === 'error' ? 'text-red-400' : 'text-blue-400'
      
      toastContent.className = `px-6 py-3 rounded-lg shadow-lg flex items-center ${
        type === 'success' ? 'bg-green-500 text-white' : 
        type === 'error' ? 'bg-red-500 text-white' : 
        'bg-blue-500 text-white'
      }`
      
      toastContent.innerHTML = `
        <svg class="w-5 h-5 mr-2 ${iconClass}" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
        </svg>
        <span>${message}</span>
      `
      
      this.toastTarget.classList.remove('hidden')
      
      setTimeout(() => {
        this.toastTarget.classList.add('hidden')
      }, 3000)
    }
  }
} 