import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "fields"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (this.checkboxTarget.checked) {
      this.fieldsTarget.classList.remove("hidden")
    } else {
      this.fieldsTarget.classList.add("hidden")
    }
  }
}
