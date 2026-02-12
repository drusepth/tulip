import { Controller } from "@hotwired/stimulus"

// Handles "Load More" pagination for the gallery page
export default class extends Controller {
  static targets = ["loadMoreButton", "buttonText", "spinner", "count"]
  static values = {
    stayId: Number,
    currentPage: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: false },
    totalCount: { type: Number, default: 0 }
  }

  connect() {
    this.loading = false
  }

  async loadMore(event) {
    event.preventDefault()
    if (this.loading || !this.hasMoreValue) return

    this.loading = true
    this.showLoadingState()

    const nextPage = this.currentPageValue + 1

    try {
      const response = await fetch(
        `/stays/${this.stayIdValue}/explore?page=${nextPage}`,
        {
          headers: {
            "Accept": "text/vnd.turbo-stream.html",
            "X-Requested-With": "XMLHttpRequest"
          }
        }
      )

      if (!response.ok) throw new Error("Failed to load more venues")

      const html = await response.text()
      Turbo.renderStreamMessage(html)

      this.currentPageValue = nextPage
      this.updateUrl(nextPage)
      this.updateCount()

      // Dispatch event for filter controller to re-apply filters
      this.dispatch("cardsLoaded", { detail: { page: nextPage } })

    } catch (error) {
      console.error("Pagination error:", error)
      this.hideLoadingState()
    } finally {
      this.loading = false
    }
  }

  showLoadingState() {
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = "Loading..."
    }
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden")
    }
    if (this.hasLoadMoreButtonTarget) {
      this.loadMoreButtonTarget.disabled = true
    }
  }

  hideLoadingState() {
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = "Load More"
    }
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden")
    }
    if (this.hasLoadMoreButtonTarget) {
      this.loadMoreButtonTarget.disabled = false
    }
  }

  updateUrl(page) {
    const url = new URL(window.location)
    url.searchParams.set("page", page)
    history.replaceState({}, "", url)
  }

  updateCount() {
    if (this.hasCountTarget) {
      const cards = this.element.querySelectorAll('[data-gallery-filter-target="card"]')
      const loadedCount = cards.length
      this.countTarget.innerHTML = `Showing ${loadedCount} of ${this.totalCountValue} venues`
    }
  }
}
