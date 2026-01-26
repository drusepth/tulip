import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content", "icon", "countLabel"]

  toggle() {
    const isHidden = this.contentTarget.classList.contains("hidden")

    if (isHidden) {
      this.contentTarget.classList.remove("hidden")
      this.iconTarget.classList.add("rotate-90")
    } else {
      this.contentTarget.classList.add("hidden")
      this.iconTarget.classList.remove("rotate-90")
    }
  }

  expand() {
    this.contentTarget.classList.remove("hidden")
    this.iconTarget.classList.add("rotate-90")
  }

  collapse() {
    this.contentTarget.classList.add("hidden")
    this.iconTarget.classList.remove("rotate-90")
  }
}
