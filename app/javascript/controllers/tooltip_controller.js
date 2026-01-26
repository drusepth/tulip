import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String, bg: String, text: String }

  connect() {
    this.tooltip = document.getElementById('tooltip')
  }

  show(event) {
    if (!this.tooltip || !this.contentValue) return

    this.tooltip.innerHTML = this.contentValue
    this.tooltip.classList.remove('hidden')

    const rect = this.element.getBoundingClientRect()
    const tooltipRect = this.tooltip.getBoundingClientRect()

    // Center above element with 8px gap
    let left = rect.left + rect.width / 2 - tooltipRect.width / 2
    let top = rect.top - tooltipRect.height - 8

    // Keep within viewport
    left = Math.max(8, Math.min(left, window.innerWidth - tooltipRect.width - 8))
    if (top < 8) top = rect.bottom + 8

    this.tooltip.style.left = `${left}px`
    this.tooltip.style.top = `${top}px`

    // Apply dynamic colors if provided
    if (this.hasBgValue) {
      this.tooltip.style.backgroundColor = this.bgValue
    }
    if (this.hasTextValue) {
      this.tooltip.style.color = this.textValue
    }
  }

  hide() {
    if (this.tooltip) {
      this.tooltip.classList.add('hidden')
      // Reset colors so other tooltips use default styling
      this.tooltip.style.backgroundColor = ''
      this.tooltip.style.color = ''
    }
  }
}
