import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popover"]

  toggle(event) {
    event.stopPropagation()
    this.popoverTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.popoverTarget.classList.add("hidden")
    }
  }

  connect() {
    this.hideHandler = this.hide.bind(this)
    document.addEventListener("click", this.hideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.hideHandler)
  }
}
