import { Controller } from "@hotwired/stimulus"

// Filters highlights items by category without making API requests
export default class extends Controller {
  static targets = ["group", "pill", "count"]
  static values = { category: { type: String, default: "all" } }

  connect() {
    this.updateActiveState()
    this.updateCount()
  }

  filter(event) {
    event.preventDefault()
    const category = event.currentTarget.dataset.category
    this.categoryValue = category
    this.filterGroups()
    this.updateActiveState()
    this.updateCount()
  }

  filterGroups() {
    this.groupTargets.forEach((group) => {
      const groupCategory = group.dataset.category
      if (this.categoryValue === "all" || groupCategory === this.categoryValue) {
        group.classList.remove("hidden")
      } else {
        group.classList.add("hidden")
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

    const visibleGroups = this.groupTargets.filter(
      (group) => !group.classList.contains("hidden")
    )

    // Count items in visible groups
    let visibleCount = 0
    visibleGroups.forEach((group) => {
      const items = group.querySelectorAll(".cozy-card")
      visibleCount += items.length
    })

    // Count total items
    let totalCount = 0
    this.groupTargets.forEach((group) => {
      const items = group.querySelectorAll(".cozy-card")
      totalCount += items.length
    })

    if (this.categoryValue === "all") {
      this.countTarget.textContent = `${totalCount} completed`
    } else {
      this.countTarget.textContent = `${visibleCount} of ${totalCount} completed`
    }
  }
}
