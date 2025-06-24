import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["salaryRange", "applicationLink"]

  connect() {
    this.updateVisibility("salary")
    this.updateVisibility("application")
  }

  toggleSalaryRange(event) {
    this.updateVisibility("salary", event.target.value)
  }

  toggleApplicationLink(event) {
    this.updateVisibility("application", event.target.value)
  }

  updateVisibility(type, selected = null) {
    if (type === "salary") {
      selected ||= this.getSelectedValue("recruitment[salary_type]")
      this.toggleElement(this.salaryRangeTarget, selected !== "fixed")
    }

    if (type === "application") {
      selected ||= this.getSelectedValue("recruitment[application_collection_method]")
      this.toggleElement(this.applicationLinkTarget, selected !== "easy_apply")
    }
  }

  getSelectedValue(fieldName) {
    const selectedInput = this.element.querySelector(`input[name="${fieldName}"]:checked`)
    return selectedInput?.value
  }

  toggleElement(element, shouldShow) {
    if (shouldShow) {
      element.classList.remove("hidden", "opacity-0")
      element.classList.add("opacity-100")
    } else {
      element.classList.remove("opacity-100")
      element.classList.add("opacity-0")
      setTimeout(() => element.classList.add("hidden"), 300)
    }
  }
}
