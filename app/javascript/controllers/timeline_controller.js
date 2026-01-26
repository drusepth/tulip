import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: String,
    end: String,
    today: String
  }

  static targets = ["track", "header", "todayMarker"]

  connect() {
    this.isDragging = false
    this.startX = 0
    this.scrollLeft = 0

    // Scroll to center today marker on load
    this.scrollToToday()

    // Set up keyboard navigation
    this.element.addEventListener("keydown", this.handleKeydown.bind(this))

    // Sync header scroll with track scroll
    if (this.hasTrackTarget && this.hasHeaderTarget) {
      this.trackTarget.addEventListener("scroll", this.syncScroll.bind(this))
    }
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown.bind(this))
    if (this.hasTrackTarget) {
      this.trackTarget.removeEventListener("scroll", this.syncScroll.bind(this))
    }
  }

  scrollToToday() {
    if (!this.hasTodayMarkerTarget || !this.hasTrackTarget) return

    // Wait for layout to complete
    requestAnimationFrame(() => {
      const track = this.trackTarget
      const marker = this.todayMarkerTarget
      const trackRect = track.getBoundingClientRect()
      const markerLeft = marker.offsetLeft

      // Center the today marker in the visible area
      const scrollPosition = markerLeft - (trackRect.width / 2)
      track.scrollLeft = Math.max(0, scrollPosition)

      // Also sync the header
      if (this.hasHeaderTarget) {
        this.headerTarget.scrollLeft = track.scrollLeft
      }
    })
  }

  syncScroll() {
    if (this.hasHeaderTarget && this.hasTrackTarget) {
      this.headerTarget.scrollLeft = this.trackTarget.scrollLeft
    }
  }

  // Drag-to-scroll functionality
  startDrag(event) {
    // Don't start drag if clicking on a link
    if (event.target.closest("a")) return

    this.isDragging = true
    this.startX = event.pageX - this.trackTarget.offsetLeft
    this.scrollLeft = this.trackTarget.scrollLeft
    this.trackTarget.style.cursor = "grabbing"
  }

  drag(event) {
    if (!this.isDragging) return
    event.preventDefault()

    const x = event.pageX - this.trackTarget.offsetLeft
    const walk = (x - this.startX) * 1.5 // Scroll speed multiplier
    this.trackTarget.scrollLeft = this.scrollLeft - walk

    // Sync header
    if (this.hasHeaderTarget) {
      this.headerTarget.scrollLeft = this.trackTarget.scrollLeft
    }
  }

  stopDrag() {
    this.isDragging = false
    if (this.hasTrackTarget) {
      this.trackTarget.style.cursor = "grab"
    }
  }

  // Keyboard navigation
  handleKeydown(event) {
    if (!this.hasTrackTarget) return

    const scrollAmount = 100

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.trackTarget.scrollLeft -= scrollAmount
        this.syncScroll()
        break
      case "ArrowRight":
        event.preventDefault()
        this.trackTarget.scrollLeft += scrollAmount
        this.syncScroll()
        break
      case "Home":
        event.preventDefault()
        this.trackTarget.scrollLeft = 0
        this.syncScroll()
        break
      case "End":
        event.preventDefault()
        this.trackTarget.scrollLeft = this.trackTarget.scrollWidth
        this.syncScroll()
        break
    }
  }
}
