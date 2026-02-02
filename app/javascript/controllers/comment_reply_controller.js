import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "textarea", "formElement"]
  static values = { parentId: String }

  showForm() {
    // If this is a nested reply, find the parent comment's form instead
    if (this.hasParentIdValue && this.parentIdValue) {
      const parentFrame = document.getElementById(this.parentIdValue)
      if (parentFrame) {
        const parentController = this.application.getControllerForElementAndIdentifier(
          parentFrame.querySelector('[data-controller~="comment-reply"]'),
          'comment-reply'
        )
        if (parentController) {
          parentController.showForm()
          return
        }
      }
    }

    // Otherwise show our own form
    if (this.hasFormTarget) {
      this.formTarget.classList.remove("hidden")
      if (this.hasTextareaTarget) {
        this.textareaTarget.focus()
      }
    }
  }

  hideForm() {
    if (this.hasFormTarget) {
      this.formTarget.classList.add("hidden")
      if (this.hasFormElementTarget) {
        this.formElementTarget.reset()
      }
    }
  }
}
