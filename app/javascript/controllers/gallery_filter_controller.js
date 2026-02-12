import { Controller } from "@hotwired/stimulus"

// Filters gallery venue cards by category without making API requests
export default class extends Controller {
  static targets = ["card", "pill", "count"]
  static values = { category: { type: String, default: "all" } }

  connect() {
    this.updateActiveState()
    this.updateCount()

    // Listen for new cards being loaded via pagination
    this.element.addEventListener("gallery-pagination:cardsLoaded", this.handleCardsLoaded.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("gallery-pagination:cardsLoaded", this.handleCardsLoaded.bind(this))
  }

  handleCardsLoaded() {
    // Re-apply current filter to newly loaded cards
    this.filterCards()
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
    const loadedCount = this.cardTargets.length

    // Get the server-side total from pagination controller's data attribute
    const paginationTotalCount = this.element.dataset.galleryPaginationTotalCountValue
    const totalCount = paginationTotalCount ? parseInt(paginationTotalCount, 10) : loadedCount

    if (this.categoryValue === "all") {
      this.countTarget.textContent = `Showing ${loadedCount} of ${totalCount} venues`
    } else {
      this.countTarget.textContent = `${visibleCount} of ${loadedCount} loaded (${totalCount} total)`
    }
  }
}
