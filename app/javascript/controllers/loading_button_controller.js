import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "spinner"]

  start() {
    // Hide the plus icon
    if (this.hasIconTarget) {
      this.iconTarget.classList.add("hidden")
    }

    // Show the spinner
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden")
    }

    // Disable after a micro-task to allow form submission to proceed
    setTimeout(() => {
      this.element.disabled = true
      this.element.classList.add("pointer-events-none", "opacity-75")
    }, 0)
  }
}
