import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tooltip", "tooltipContent"]

  connect() {
    // Bind click handler for navigating to stays
    this.element.addEventListener("click", this.handleClick.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick.bind(this))
  }

  handleClick(event) {
    const dayEl = event.target.closest(".year-grid-day")
    if (!dayEl) return

    const stayPath = dayEl.dataset.stayPath
    if (stayPath) {
      window.location.href = stayPath
    }
  }

  showTooltip(event) {
    const dayEl = event.target
    if (!this.hasTooltipTarget || !this.hasTooltipContentTarget) return

    const date = dayEl.dataset.date
    const stayTitle = dayEl.dataset.stayTitle
    const stayCity = dayEl.dataset.stayCity
    const stayStatus = dayEl.dataset.stayStatus
    const isGap = dayEl.dataset.isGap === "true"
    const gapDays = dayEl.dataset.gapDays

    // Format date
    const dateObj = new Date(date + "T00:00:00")
    const formattedDate = dateObj.toLocaleDateString("en-US", {
      weekday: "short",
      month: "short",
      day: "numeric",
      year: "numeric"
    })

    let content = `<div class="text-xs text-brown-lighter">${formattedDate}</div>`

    if (stayTitle) {
      const statusClass = {
        upcoming: "badge-upcoming",
        current: "badge-current",
        past: "badge-past"
      }[stayStatus] || "badge-planned"

      content += `
        <div class="font-semibold text-brown mt-1">${this.escapeHtml(stayTitle)}</div>
        <div class="text-sm text-brown-light">${this.escapeHtml(stayCity)}</div>
        <span class="badge ${statusClass} mt-1">${stayStatus ? stayStatus.charAt(0).toUpperCase() + stayStatus.slice(1) : "Planned"}</span>
        <div class="text-xs text-sage-dark mt-2">Click to view</div>
      `
    } else if (isGap) {
      content += `
        <div class="font-semibold text-coral-dark mt-1">${gapDays} day gap</div>
        <div class="text-xs text-brown-light">No accommodation booked</div>
      `
    } else {
      content += `
        <div class="text-sm text-brown-light mt-1">No stay</div>
      `
    }

    this.tooltipContentTarget.innerHTML = content
    this.tooltipTarget.classList.remove("hidden")

    // Position tooltip
    const rect = dayEl.getBoundingClientRect()
    const tooltipRect = this.tooltipTarget.getBoundingClientRect()
    const containerRect = this.element.getBoundingClientRect()

    let left = rect.left - containerRect.left + rect.width / 2 - tooltipRect.width / 2
    let top = rect.top - containerRect.top - tooltipRect.height - 8

    // Keep tooltip in bounds
    if (left < 0) left = 0
    if (left + tooltipRect.width > containerRect.width) {
      left = containerRect.width - tooltipRect.width
    }
    if (top < 0) {
      top = rect.bottom - containerRect.top + 8
    }

    this.tooltipTarget.style.left = `${left}px`
    this.tooltipTarget.style.top = `${top}px`
  }

  hideTooltip() {
    if (this.hasTooltipTarget) {
      this.tooltipTarget.classList.add("hidden")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
