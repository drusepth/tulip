import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: String,
    end: String,
    today: String
  }

  static targets = ["track", "header", "todayMarker", "minimap", "minimapTrack", "minimapViewport"]

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

    // Initialize mini-map viewport
    if (this.hasMinimapViewportTarget) {
      this.updateMinimapViewport()
    }

    // Collect stay and gap positions for keyboard navigation
    this.collectItemPositions()
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown.bind(this))
    if (this.hasTrackTarget) {
      this.trackTarget.removeEventListener("scroll", this.syncScroll.bind(this))
    }
  }

  collectItemPositions() {
    this.stayPositions = []
    this.gapPositions = []

    const track = this.trackTarget
    if (!track) return

    const bars = track.querySelectorAll(".timeline-bar")
    bars.forEach(bar => {
      const left = parseFloat(bar.style.left)
      if (bar.classList.contains("timeline-gap-bar")) {
        this.gapPositions.push(left)
      } else {
        this.stayPositions.push(left)
      }
    })

    // Sort by position
    this.stayPositions.sort((a, b) => a - b)
    this.gapPositions.sort((a, b) => a - b)
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

      // Update mini-map
      this.updateMinimapViewport()
    })
  }

  syncScroll() {
    if (this.hasHeaderTarget && this.hasTrackTarget) {
      this.headerTarget.scrollLeft = this.trackTarget.scrollLeft
    }
    this.updateMinimapViewport()
  }

  updateMinimapViewport() {
    if (!this.hasMinimapViewportTarget || !this.hasTrackTarget) return

    const track = this.trackTarget
    const viewport = this.minimapViewportTarget

    // Calculate viewport width as percentage of total
    const viewportWidthPercent = (track.clientWidth / track.scrollWidth) * 100
    // Calculate viewport position as percentage
    const viewportLeftPercent = (track.scrollLeft / track.scrollWidth) * 100

    viewport.style.width = `${Math.max(viewportWidthPercent, 5)}%`
    viewport.style.left = `${viewportLeftPercent}%`
  }

  // Click on mini-map to jump to that position
  jumpToPosition(event) {
    if (!this.hasTrackTarget || !this.hasMinimapTrackTarget) return

    const minimap = this.minimapTrackTarget
    const rect = minimap.getBoundingClientRect()
    const clickX = event.clientX - rect.left
    const clickPercent = clickX / rect.width

    const track = this.trackTarget
    const targetScroll = (clickPercent * track.scrollWidth) - (track.clientWidth / 2)

    track.scrollTo({
      left: Math.max(0, targetScroll),
      behavior: "smooth"
    })
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
        this.trackTarget.scrollTo({ left: 0, behavior: "smooth" })
        this.syncScroll()
        break
      case "End":
        event.preventDefault()
        this.trackTarget.scrollTo({ left: this.trackTarget.scrollWidth, behavior: "smooth" })
        this.syncScroll()
        break
      case "t":
      case "T":
        // Jump to today
        event.preventDefault()
        this.scrollToToday()
        break
      case "n":
      case "N":
        // Jump to next upcoming stay
        event.preventDefault()
        this.jumpToNextStay()
        break
      case "g":
      case "G":
        // Jump to next gap
        event.preventDefault()
        this.jumpToNextGap()
        break
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
        // Quick zoom levels (would require page reload with new zoom param)
        // These are informational - actual zoom requires clicking the zoom buttons
        break
    }
  }

  jumpToNextStay() {
    if (!this.hasTrackTarget || this.stayPositions.length === 0) return

    const track = this.trackTarget
    const currentScrollPercent = (track.scrollLeft + track.clientWidth / 2) / track.scrollWidth * 100

    // Find next stay after current position
    const nextPos = this.stayPositions.find(pos => pos > currentScrollPercent + 1)

    if (nextPos !== undefined) {
      const targetScroll = (nextPos / 100) * track.scrollWidth - track.clientWidth / 2
      track.scrollTo({
        left: Math.max(0, targetScroll),
        behavior: "smooth"
      })
    } else if (this.stayPositions.length > 0) {
      // Wrap to first stay
      const firstPos = this.stayPositions[0]
      const targetScroll = (firstPos / 100) * track.scrollWidth - track.clientWidth / 2
      track.scrollTo({
        left: Math.max(0, targetScroll),
        behavior: "smooth"
      })
    }
  }

  jumpToNextGap() {
    if (!this.hasTrackTarget || this.gapPositions.length === 0) return

    const track = this.trackTarget
    const currentScrollPercent = (track.scrollLeft + track.clientWidth / 2) / track.scrollWidth * 100

    // Find next gap after current position
    const nextPos = this.gapPositions.find(pos => pos > currentScrollPercent + 1)

    if (nextPos !== undefined) {
      const targetScroll = (nextPos / 100) * track.scrollWidth - track.clientWidth / 2
      track.scrollTo({
        left: Math.max(0, targetScroll),
        behavior: "smooth"
      })
    } else if (this.gapPositions.length > 0) {
      // Wrap to first gap
      const firstPos = this.gapPositions[0]
      const targetScroll = (firstPos / 100) * track.scrollWidth - track.clientWidth / 2
      track.scrollTo({
        left: Math.max(0, targetScroll),
        behavior: "smooth"
      })
    }
  }
}
