import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "hint"]
  static values = {
    url: String,
    current: Number
  }

  static starPath = "M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"

  connect() {
    // Store original sizes from each star's SVG
    this.starSizes = this.starTargets.map(star => {
      const svg = star.querySelector('svg')
      if (svg) {
        // Extract size classes (e.g., w-4, w-6, w-10, h-4, h-6, h-10)
        const classes = Array.from(svg.classList)
        const sizeClasses = classes.filter(c => /^[wh]-\d+$/.test(c))
        return sizeClasses.join(' ') || 'w-4 h-4'
      }
      return 'w-4 h-4'
    })
    this.updateStars(this.currentValue)
  }

  getFilledStarSvg(sizeClasses) {
    return `<svg class="${sizeClasses} text-coral" data-filled="true" fill="currentColor" viewBox="0 0 24 24">
      <path d="${this.constructor.starPath}"/>
    </svg>`
  }

  getOutlinedStarSvg(sizeClasses) {
    return `<svg class="${sizeClasses} text-taupe" data-filled="false" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" d="${this.constructor.starPath}"/>
    </svg>`
  }

  preview(event) {
    const starNum = parseInt(event.currentTarget.dataset.starNum)
    this.updateStars(starNum)
  }

  restore() {
    this.updateStars(this.currentValue)
  }

  async rate(event) {
    const starNum = parseInt(event.currentTarget.dataset.starNum)

    // Toggle off if clicking same star
    if (starNum === this.currentValue) {
      await this.removeRating()
    } else {
      await this.setRating(starNum)
    }
  }

  async setRating(rating) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': csrfToken
        },
        body: `rating=${rating}`
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error('Error setting rating:', error)
      this.restore()
    }
  }

  async removeRating() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.urlValue, {
        method: 'DELETE',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': csrfToken
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error('Error removing rating:', error)
      this.restore()
    }
  }

  updateStars(rating) {
    this.starTargets.forEach((star, index) => {
      const starNum = parseInt(star.dataset.starNum)
      const shouldBeFilled = starNum <= rating
      const sizeClasses = this.starSizes[index] || 'w-4 h-4'

      // Replace the SVG with filled or outlined version, preserving size
      if (shouldBeFilled) {
        star.innerHTML = this.getFilledStarSvg(sizeClasses)
      } else {
        star.innerHTML = this.getOutlinedStarSvg(sizeClasses)
      }
    })
  }
}
