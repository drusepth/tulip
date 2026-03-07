import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "slidesContainer", "dot", "counter", "prevBtn", "nextBtn"]
  static values = {
    index: { type: Number, default: 0 }
  }

  connect() {
    this.updateDisplay(false) // No animation on initial load
  }

  prev() {
    if (this.indexValue > 0) {
      this.indexValue--
      this.updateDisplay(true, 'left')
    }
  }

  next() {
    if (this.indexValue < this.slideTargets.length - 1) {
      this.indexValue++
      this.updateDisplay(true, 'right')
    }
  }

  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    if (index >= 0 && index < this.slideTargets.length && index !== this.indexValue) {
      const direction = index > this.indexValue ? 'right' : 'left'
      this.indexValue = index
      this.updateDisplay(true, direction)
    }
  }

  updateDisplay(animate = false, direction = 'right') {
    const totalSlides = this.slideTargets.length

    // Animate slides
    this.slideTargets.forEach((slide, i) => {
      if (i === this.indexValue) {
        // Show the current slide with animation
        slide.classList.remove("hidden")

        if (animate) {
          // Set initial position based on direction
          slide.style.transform = direction === 'right' ? 'translateX(100%)' : 'translateX(-100%)'
          slide.style.opacity = '0'

          // Force reflow to ensure the initial state is applied
          slide.offsetHeight

          // Animate to center
          slide.style.transition = 'transform 300ms ease-out, opacity 300ms ease-out'
          slide.style.transform = 'translateX(0)'
          slide.style.opacity = '1'
        } else {
          slide.style.transform = 'translateX(0)'
          slide.style.opacity = '1'
          slide.style.transition = 'none'
        }
      } else {
        // Hide other slides
        if (animate && !slide.classList.contains('hidden')) {
          // Animate out
          slide.style.transition = 'transform 300ms ease-out, opacity 300ms ease-out'
          slide.style.transform = direction === 'right' ? 'translateX(-100%)' : 'translateX(100%)'
          slide.style.opacity = '0'

          // Hide after animation completes
          setTimeout(() => {
            slide.classList.add("hidden")
            slide.style.transform = ''
            slide.style.opacity = ''
            slide.style.transition = ''
          }, 300)
        } else {
          slide.classList.add("hidden")
        }
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
    this.updateDisplay(false)
  }
}
