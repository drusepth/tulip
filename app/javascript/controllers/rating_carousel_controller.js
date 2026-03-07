import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot", "counter", "prevBtn", "nextBtn"]
  static values = {
    index: { type: Number, default: 0 }
  }

  connect() {
    this.updateDisplay()
  }

  prev() {
    if (this.indexValue > 0) {
      this.indexValue--
      this.updateDisplay()
    }
  }

  next() {
    if (this.indexValue < this.slideTargets.length - 1) {
      this.indexValue++
      this.updateDisplay()
    }
  }

  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    if (index >= 0 && index < this.slideTargets.length) {
      this.indexValue = index
      this.updateDisplay()
    }
  }

  updateDisplay() {
    const totalSlides = this.slideTargets.length

    // Show/hide slides
    this.slideTargets.forEach((slide, i) => {
      if (i === this.indexValue) {
        slide.classList.remove("hidden")
      } else {
        slide.classList.add("hidden")
      }
    })

    // Update dot indicators
    if (this.hasDotTarget) {
      this.dotTargets.forEach((dot, i) => {
        if (i === this.indexValue) {
          dot.classList.remove("bg-taupe-light")
          dot.classList.add("bg-coral")
        } else {
          dot.classList.remove("bg-coral")
          dot.classList.add("bg-taupe-light")
        }
      })
    }

    // Update counter
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.indexValue + 1} of ${totalSlides}`
    }

    // Update prev/next button visibility
    if (this.hasPrevBtnTarget) {
      if (this.indexValue === 0) {
        this.prevBtnTarget.classList.add("invisible")
      } else {
        this.prevBtnTarget.classList.remove("invisible")
      }
    }

    if (this.hasNextBtnTarget) {
      if (this.indexValue >= totalSlides - 1) {
        this.nextBtnTarget.classList.add("invisible")
      } else {
        this.nextBtnTarget.classList.remove("invisible")
      }
    }
  }

  // Called when a slide is removed (e.g., after rating)
  slideRemoved() {
    const totalSlides = this.slideTargets.length
    if (this.indexValue >= totalSlides && totalSlides > 0) {
      this.indexValue = totalSlides - 1
    }
    this.updateDisplay()
  }
}
