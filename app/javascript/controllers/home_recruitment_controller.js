import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "viewMoreBtn"]

  connect() {
    console.log("Home recruitment controller connected")
  }

  viewRecruitment(event) {
    const recruitmentId = event.currentTarget.dataset.recruitmentId
    if (recruitmentId) {
      window.location.href = `/recruitment/${recruitmentId}`
    }
  }

  viewMoreJobs(event) {
    event.preventDefault()
    window.location.href = "/jobs"
  }

  viewMoreInternships(event) {
    event.preventDefault()
    window.location.href = "/internships"
  }

  cardHover(event) {
    const card = event.currentTarget
    card.classList.add("shadow-lg", "scale-105")
    card.classList.remove("shadow-sm")
  }

  cardLeave(event) {
    const card = event.currentTarget
    card.classList.remove("shadow-lg", "scale-105")
    card.classList.add("shadow-sm")
  }
} 