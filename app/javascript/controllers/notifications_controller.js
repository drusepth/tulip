import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "badge", "list"]

  connect() {
    this.hideHandler = this.hide.bind(this)
    document.addEventListener("click", this.hideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.hideHandler)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.panelTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.loadNotifications()
  }

  close() {
    this.panelTarget.classList.add("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  async loadNotifications() {
    try {
      const response = await fetch("/notifications", {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.listTarget.innerHTML = html
      }
    } catch (error) {
      console.error("Failed to load notifications:", error)
      this.listTarget.innerHTML = '<div class="p-4 text-center text-rose">Failed to load notifications</div>'
    }
  }

  async markAsRead(event) {
    const notificationEl = event.target.closest("[data-notification-id]")
    if (!notificationEl) return

    const notificationId = notificationEl.dataset.notificationId
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      await fetch(`/notifications/${notificationId}/mark_read`, {
        method: "POST",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": csrfToken
        }
      })
    } catch (error) {
      console.error("Failed to mark notification as read:", error)
    }
  }

  async markAllRead(event) {
    event.preventDefault()
    event.stopPropagation()

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch("/notifications/mark_all_read", {
        method: "POST",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": csrfToken
        }
      })

      if (response.ok) {
        // Turbo Stream will handle the update
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Failed to mark all notifications as read:", error)
    }
  }

  navigate(event) {
    const notificationEl = event.target.closest("[data-notification-id]")
    if (!notificationEl) return

    // Mark as read when clicking
    this.markAsRead(event)

    // Close the panel
    this.close()
  }
}
