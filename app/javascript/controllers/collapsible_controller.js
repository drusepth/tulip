import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content", "icon", "countLabel"]

  toggle(event) {
    if (!this.hasContentTarget) return

    const isHidden = this.contentTarget.classList.contains("hidden")

    if (isHidden) {
      this.contentTarget.classList.remove("hidden")
      if (this.hasIconTarget) this.iconTarget.classList.add("rotate-180")
    } else {
      this.contentTarget.classList.add("hidden")
      if (this.hasIconTarget) this.iconTarget.classList.remove("rotate-180")
    }
  }

  expand() {
    if (!this.hasContentTarget) return
    this.contentTarget.classList.remove("hidden")
    if (this.hasIconTarget) this.iconTarget.classList.add("rotate-180")
  }

  collapse() {
    if (!this.hasContentTarget) return
    this.contentTarget.classList.add("hidden")
    if (this.hasIconTarget) this.iconTarget.classList.remove("rotate-180")
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
