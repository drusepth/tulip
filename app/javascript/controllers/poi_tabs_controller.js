import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]

  connect() {
    // Listen for Turbo stream responses to clear loading state
    document.addEventListener("turbo:before-stream-render", this.clearLoading.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.clearLoading.bind(this))
  }

  showLoading(event) {
    const clickedTab = event.currentTarget

    // Add loading class to the clicked tab
    clickedTab.classList.add("loading")

    // Store reference to loading tab for cleanup
    this.loadingTab = clickedTab
  }

  clearLoading() {
    // Remove loading class from any tab that has it
    if (this.loadingTab) {
      this.loadingTab.classList.remove("loading")
      this.loadingTab = null
    }

    // Also clear any other loading tabs (fallback)
    this.tabTargets.forEach(tab => tab.classList.remove("loading"))
  }
}
