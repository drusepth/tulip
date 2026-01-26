import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleInput", "extraFields", "expandButton", "expandLabel"]

  connect() {
    this.expanded = false
    this.element.addEventListener("turbo:submit-end", this.handleSubmit.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmit.bind(this))
  }

  toggleExpand() {
    if (this.expanded) {
      this.collapse()
    } else {
      this.expand()
    }
  }

  expand() {
    this.expanded = true
    this.extraFieldsTarget.classList.remove("hidden")
    this.expandLabelTarget.textContent = "Hide extra fields"

    // Change plus icon to minus
    const svg = this.expandButtonTarget.querySelector("svg")
    svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path>'
  }

  collapse() {
    this.expanded = false
    this.extraFieldsTarget.classList.add("hidden")
    this.expandLabelTarget.textContent = "Add location or notes"

    // Change minus icon to plus
    const svg = this.expandButtonTarget.querySelector("svg")
    svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>'
  }

  handleSubmit(event) {
    if (event.detail.success) {
      this.collapse()
      this.titleInputTarget.value = ""
      this.titleInputTarget.focus()
    }
  }
}
