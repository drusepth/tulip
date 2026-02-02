import { Controller } from "@hotwired/stimulus"

// Filters gallery venue cards by category without making API requests
export default class extends Controller {
  static targets = ["card", "pill", "count"]
  static values = { category: { type: String, default: "all" } }

  connect() {
    this.updateActiveState()
    this.updateCount()
  }

  filter(event) {
    event.preventDefault()
    const category = event.currentTarget.dataset.category
    this.categoryValue = category
    this.filterCards()
    this.updateActiveState()
    this.updateCount()
  }

  filterCards() {
    this.cardTargets.forEach((card) => {
      const cardCategory = card.dataset.category
      if (this.categoryValue === "all" || cardCategory === this.categoryValue) {
        card.classList.remove("hidden")
      } else {
        card.classList.add("hidden")
      }
    })
  }

  updateActiveState() {
    this.pillTargets.forEach((pill) => {
      const pillCategory = pill.dataset.category
      if (pillCategory === this.categoryValue) {
        pill.classList.add("active")
      } else {
        pill.classList.remove("active")
      }
    })
  }

  updateCount() {
    if (!this.hasCountTarget) return

    const visibleCount = this.cardTargets.filter(
      (card) => !card.classList.contains("hidden")
    ).length
    const totalCount = this.cardTargets.length

    if (this.categoryValue === "all") {
      this.countTarget.textContent = `${totalCount} venues`
    } else {
      this.countTarget.textContent = `${visibleCount} of ${totalCount} venues`
    }
  }
}
