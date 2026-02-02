import { Controller } from "@hotwired/stimulus"
// Leaflet is loaded globally via CDN in application.html.erb

export default class extends Controller {
  static targets = ["container", "timeline", "upcomingStaysList", "previousStaysList", "previousStaysToggle", "previousStaysChevron", "previousStaysCount", "dreamDestinationsList", "dreamDestinationsToggle", "dreamDestinationsChevron", "dreamDestinationsCount", "collapseIcon", "floatingCard", "floatingCardTitle", "floatingCardLocation", "floatingCardDates", "bucketListToggle"]
  static values = {
    staysUrl: String,
    poisUrl: String,
    transitUrl: String,
    poisSearchUrl: String,
    bucketListUrl: String
  }

  connect() {
    this.initializeMap()
    this.loadStays()
    this.poiLayers = {}
    this.transitLayers = {}
    this.activeCategories = new Set()
    this.activeTransitTypes = new Set()
    this.stayMarkers = []
    this.fetchedPOIs = {}      // Track fetched POIs by `${category}-${stayId}`
    this.fetchedTransit = {}   // Track fetched transit by `${routeType}-${stayId}`
    this.previousStaysVisible = false  // Track visibility of previous stays markers
    this.previousStayMarkers = []      // Separate array for previous stay markers
    this.dreamDestinationsVisible = false  // Track visibility of dream destinations
    this.dreamDestinationMarkers = []      // Separate array for dream destination markers
    this.poiAbortControllers = {}    // AbortControllers for in-flight POI requests
    this.transitAbortControllers = {} // AbortControllers for in-flight transit requests
    this.searchedGridCells = {}      // Track searched viewport grid cells by `${category}-${gridKey}`
    this.viewportSearchAbortControllers = {} // AbortControllers for viewport POI searches
    this.viewportChangeTimeout = null // Debounce timeout for viewport changes
    this.loadingCounts = {}    // Track in-flight request counts per category/routeType
    this.bucketListLayer = null      // Layer group for bucket list markers
    this.bucketListVisible = false   // Track visibility of bucket list markers
    this.bucketListItems = null      // Cached bucket list items

    // Auto-load POIs/transit when viewport changes
    this.map.on('moveend', () => this.onViewportChange())

    // Listen for clicks on bucket list buttons in popups
    this.bucketListClickHandler = this.handleBucketListClick.bind(this)
    document.addEventListener('click', this.bucketListClickHandler)
  }

  async handleBucketListClick(event) {
    const btn = event.target.closest('.add-to-bucket-list-btn')
    if (!btn) return

    const stayId = btn.dataset.stayId
    const poiName = btn.dataset.poiName
    const poiAddress = btn.dataset.poiAddress

    // Show loading state
    btn.disabled = true
    btn.innerHTML = `
      <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Adding...
    `

    try {
      const response = await fetch(`/stays/${stayId}/bucket_list_items`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          bucket_list_item: {
            title: poiName,
            address: poiAddress,
            category: 'other'
          }
        })
      })

      if (response.ok) {
        btn.classList.add('success')
        btn.innerHTML = `
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
          Added!
        `
      } else {
        throw new Error('Failed to add')
      }
    } catch (error) {
      btn.disabled = false
      btn.classList.add('error')
      btn.innerHTML = `
        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
        Try again
      `
    }
  }

  // Handle layer toggle events from the layers panel controller
  handleLayerToggle(event) {
    const { type, key, active } = event.detail

    if (type === 'poi') {
      if (active) {
        this.activeCategories.add(key)
        this.loadPOIs(key)
        this.searchViewportPOIs(key)
      } else {
        this.activeCategories.delete(key)
        this.removePOILayer(key)
      }
    } else if (type === 'transit') {
      if (active) {
        this.activeTransitTypes.add(key)
        this.loadTransitRoutes(key)
      } else {
        this.activeTransitTypes.delete(key)
        this.removeTransitLayer(key)
      }
    } else if (type === 'bucket-list') {
      if (active) {
        this.bucketListVisible = true
        this.loadBucketListItems()
      } else {
        this.bucketListVisible = false
        this.removeBucketListLayer()
      }
    }
  }

  // Loading state helpers
  startLoading(type, key) {
    const loadingKey = `${type}-${key}`
    this.loadingCounts[loadingKey] = (this.loadingCounts[loadingKey] || 0) + 1
    // Dispatch event for layers panel to show loading state
    document.dispatchEvent(new CustomEvent('map:loading-start', {
      detail: { type, key }
    }))
  }

  stopLoading(type, key) {
    const loadingKey = `${type}-${key}`
    this.loadingCounts[loadingKey] = Math.max(0, (this.loadingCounts[loadingKey] || 1) - 1)
    if (this.loadingCounts[loadingKey] === 0) {
      // Dispatch event for layers panel to hide loading state
      document.dispatchEvent(new CustomEvent('map:loading-stop', {
        detail: { type, key }
      }))
    }
  }

  onViewportChange() {
    // Debounce viewport changes to avoid excessive API calls while panning
    if (this.viewportChangeTimeout) {
      clearTimeout(this.viewportChangeTimeout)
    }

    this.viewportChangeTimeout = setTimeout(() => {
      // Reload active POI categories for newly visible stays
      this.activeCategories.forEach(category => this.loadPOIs(category))
      this.activeTransitTypes.forEach(routeType => this.loadTransitRoutes(routeType))

      // Also search for POIs around viewport center
      this.activeCategories.forEach(category => this.searchViewportPOIs(category))
    }, 300)
  }

  initializeMap() {
    const mapElement = this.hasContainerTarget ? this.containerTarget : this.element
    this.map = L.map(mapElement, { zoomControl: false }).setView([20, 0], 2)

    // Add zoom control with custom position (offset for timeline panel)
    this.zoomControl = L.control.zoom({ position: 'topleft' })
    this.zoomControl.addTo(this.map)
    this.updateZoomControlPosition(false) // Panel starts open

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)
  }

  updateZoomControlPosition(collapsed) {
    const container = this.zoomControl.getContainer()
    if (collapsed) {
      container.style.marginLeft = '10px'
    } else {
      container.style.marginLeft = '330px' // 320px panel + 10px padding
    }
  }

  async loadStays() {
    try {
      const response = await fetch(this.staysUrlValue)
      const stays = await response.json()
      this.stays = stays
      this.renderStayMarkers(stays)
      this.renderTimeline(stays)
      this.focusOnStayFromUrl()
    } catch (error) {
      console.error('Failed to load stays:', error)
    }
  }

  focusOnStayFromUrl() {
    const params = new URLSearchParams(window.location.search)
    const focusId = params.get('focus')
    if (!focusId || !this.stays) return

    const stay = this.stays.find(s => s.id == focusId)
    if (stay && stay.latitude && stay.longitude) {
      // If it's a previous stay and markers are hidden, show them first
      if (stay.status === 'past' && !this.previousStaysVisible) {
        this.togglePreviousStays()
      }
      // If it's a dream destination and markers are hidden, show them first
      if (stay.wishlist && !this.dreamDestinationsVisible) {
        this.toggleDreamDestinations()
      }
      this.map.setView([stay.latitude, stay.longitude], 14)
      this.showFloatingCard(stay, stay.wishlist)
    }
  }

  renderStayMarkers(stays) {
    const bounds = []
    // Filter out wishlist stays (no dates) from upcoming
    const upcomingStays = stays.filter(s => (s.status === 'upcoming' || s.status === 'current') && !s.wishlist)
    const previousStays = stays.filter(s => s.status === 'past')
    const dreamDestinations = stays.filter(s => s.wishlist)

    // Render upcoming/current stays (always visible)
    upcomingStays.forEach(stay => {
      if (stay.latitude && stay.longitude) {
        const marker = this.createStayMarker(stay)
        marker.addTo(this.map)
        this.stayMarkers.push({ marker, stay })
        bounds.push([stay.latitude, stay.longitude])
      }
    })

    // Render previous stays (hidden by default)
    previousStays.forEach(stay => {
      if (stay.latitude && stay.longitude) {
        const marker = this.createStayMarker(stay)
        // Don't add to map initially - they're hidden by default
        this.previousStayMarkers.push({ marker, stay })
      }
    })

    // Render dream destinations (hidden by default)
    dreamDestinations.forEach(stay => {
      if (stay.latitude && stay.longitude) {
        const marker = this.createStayMarker(stay, true)
        // Don't add to map initially - they're hidden by default
        this.dreamDestinationMarkers.push({ marker, stay })
      }
    })

    // Only auto-fit bounds if no focus parameter is present
    const params = new URLSearchParams(window.location.search)
    if (bounds.length > 0 && !params.get('focus')) {
      this.map.fitBounds(bounds, { padding: [50, 50] })
    }
  }

  createStayMarker(stay, isDream = false) {
    const color = isDream ? '#a78bfa' : this.getStatusColor(stay.status) // lavender for dreams
    const marker = L.circleMarker([stay.latitude, stay.longitude], {
      radius: isDream ? 8 : 10,
      fillColor: color,
      color: '#fff',
      weight: 2,
      opacity: 1,
      fillOpacity: isDream ? 0.6 : 0.8
    })

    const statusBadge = isDream
      ? `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-purple-100 text-purple-800">Dream</span>`
      : stay.booked
        ? `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-800">Booked</span>`
        : `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-purple-100 text-purple-800">Planned</span>`

    const imageHtml = stay.image_url
      ? `<div class="popup-image">
           <img src="${stay.image_url}" alt="${stay.title}"/>
         </div>`
      : ''

    // Only format dates if the stay has them (not a dream destination)
    let datesHtml = ''
    let nightsHtml = ''
    if (!isDream && stay.check_in && stay.check_out) {
      const checkIn = new Date(stay.check_in).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      const checkOut = new Date(stay.check_out).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
      datesHtml = `<p class="popup-dates">${checkIn} - ${checkOut}</p>`
      nightsHtml = `<span class="popup-nights">${stay.duration_days} nights</span>`
    } else if (isDream) {
      datesHtml = `<p class="popup-dates text-lavender-dark italic">Dates not set yet</p>`
    }

    marker.bindPopup(`
      <div class="popup-content">
        ${imageHtml}
        <div class="popup-body">
          <div class="popup-badges">
            ${statusBadge}
            ${nightsHtml}
          </div>
          <h3 class="popup-title">${stay.title}</h3>
          ${datesHtml}
          <a href="${stay.url}" class="popup-link">
            View Details
            <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
            </svg>
          </a>
        </div>
      </div>
    `, { className: 'cozy-popup', maxWidth: 260 })

    return marker
  }

  getStatusColor(status) {
    switch (status) {
      case 'upcoming': return '#22c55e' // green
      case 'current': return '#3b82f6'  // blue
      case 'past': return '#9ca3af'     // gray
      default: return '#6b7280'
    }
  }

  renderTimeline(stays) {
    // Split stays into upcoming/current, past, and dream destinations (wishlist)
    const upcomingStays = stays.filter(s => (s.status === 'upcoming' || s.status === 'current') && !s.wishlist)
    const previousStays = stays.filter(s => s.status === 'past')
    const dreamDestinations = stays.filter(s => s.wishlist)

    // Sort upcoming by check_in date (ascending - soonest first)
    const sortedUpcoming = [...upcomingStays].sort((a, b) => new Date(a.check_in) - new Date(b.check_in))
    // Sort previous by check_in date (descending - most recent first)
    const sortedPrevious = [...previousStays].sort((a, b) => new Date(b.check_in) - new Date(a.check_in))
    // Sort dream destinations alphabetically by title
    const sortedDreams = [...dreamDestinations].sort((a, b) => a.title.localeCompare(b.title))

    // Render upcoming stays
    if (this.hasUpcomingStaysListTarget) {
      if (sortedUpcoming.length === 0) {
        this.upcomingStaysListTarget.innerHTML = `
          <div class="text-center py-6 text-brown-lighter">
            <svg class="w-10 h-10 mx-auto mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
            </svg>
            <p class="text-sm">No upcoming stays</p>
          </div>
        `
      } else {
        this.upcomingStaysListTarget.innerHTML = sortedUpcoming.map(stay => this.renderStayCard(stay)).join('')
      }
    }

    // Render dream destinations
    if (this.hasDreamDestinationsListTarget) {
      this.dreamDestinationsListTarget.innerHTML = sortedDreams.map(stay => this.renderStayCard(stay, false, true)).join('')
    }

    // Update dream destinations count
    if (this.hasDreamDestinationsCountTarget) {
      this.dreamDestinationsCountTarget.textContent = `${dreamDestinations.length}`
    }

    // Render previous stays
    if (this.hasPreviousStaysListTarget) {
      this.previousStaysListTarget.innerHTML = sortedPrevious.map(stay => this.renderStayCard(stay, true)).join('')
    }

    // Update previous stays count
    if (this.hasPreviousStaysCountTarget) {
      this.previousStaysCountTarget.textContent = `${previousStays.length} ${previousStays.length === 1 ? 'stay' : 'stays'}`
    }
  }

  renderStayCard(stay, isPrevious = false, isDream = false) {
    const location = [stay.city, stay.country].filter(Boolean).join(', ')

    // Only format dates if not a dream destination
    let datesHtml = ''
    if (!isDream && stay.check_in && stay.check_out) {
      const checkIn = new Date(stay.check_in).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      const checkOut = new Date(stay.check_out).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      datesHtml = `<div class="text-xs text-brown-lighter mt-0.5">${checkIn} - ${checkOut}</div>`
    } else if (isDream) {
      datesHtml = `<div class="text-xs text-lavender mt-0.5 italic">Someday...</div>`
    }

    let imageHtml
    if (isDream) {
      imageHtml = stay.image_url
        ? `<img src="${stay.image_url}" alt="${stay.title}" class="w-20 h-full absolute left-0 top-0 bottom-0 object-cover">`
        : `<div class="w-20 h-full absolute left-0 top-0 bottom-0 bg-lavender-light flex items-center justify-center">
             <svg class="w-8 h-8 text-lavender-dark" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
             </svg>
           </div>`
    } else {
      imageHtml = stay.image_url
        ? `<img src="${stay.image_url}" alt="${stay.title}" class="w-20 h-full absolute left-0 top-0 bottom-0 object-cover ${isPrevious ? 'grayscale opacity-70' : ''}">`
        : `<div class="w-20 h-full absolute left-0 top-0 bottom-0 ${isPrevious ? 'bg-gray-200' : 'bg-taupe-light'} flex items-center justify-center">
             <svg class="w-8 h-8 ${isPrevious ? 'text-gray-400' : 'text-taupe'}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
             </svg>
           </div>`
    }

    let cardClasses
    if (isDream) {
      cardClasses = 'w-full text-left rounded-xl border border-lavender-light overflow-hidden relative transition-all duration-200 hover:shadow-md hover:border-lavender hover:-translate-y-0.5 cursor-pointer'
    } else if (isPrevious) {
      cardClasses = 'w-full text-left rounded-xl border border-gray-200 overflow-hidden relative transition-all duration-200 hover:shadow-md hover:border-taupe hover:-translate-y-0.5 cursor-pointer'
    } else {
      cardClasses = 'w-full text-left rounded-xl border border-taupe-light overflow-hidden relative transition-all duration-200 hover:shadow-md hover:border-sage hover:-translate-y-0.5 cursor-pointer'
    }

    const textClasses = isPrevious ? 'text-brown-light' : (isDream ? 'text-lavender-dark' : 'text-brown')

    return `
      <button data-action="click->map#zoomToStay" data-stay-id="${stay.id}" data-is-dream="${isDream}"
              class="${cardClasses}">
        ${imageHtml}
        <div class="ml-20 py-2 px-3 bg-white">
          <div class="font-medium ${textClasses} truncate">${stay.title}</div>
          <div class="text-sm text-brown-light">${location}</div>
          ${datesHtml}
        </div>
      </button>
    `
  }

  zoomToStay(event) {
    const stayId = event.currentTarget.dataset.stayId
    const isDream = event.currentTarget.dataset.isDream === 'true'
    const stay = this.stays.find(s => s.id == stayId)
    if (stay && stay.latitude && stay.longitude) {
      // If it's a previous stay and markers are hidden, show them first
      if (stay.status === 'past' && !this.previousStaysVisible) {
        this.togglePreviousStays()
      }
      // If it's a dream destination and markers are hidden, show them first
      if ((stay.wishlist || isDream) && !this.dreamDestinationsVisible) {
        this.toggleDreamDestinations()
      }
      this.map.setView([stay.latitude, stay.longitude], 14, { animate: true })
      this.showFloatingCard(stay, isDream)
    }
  }

  showFloatingCard(stay, isDream = false) {
    this.selectedStay = stay
    this.floatingCardTitleTarget.textContent = stay.title
    const location = [stay.city, stay.country].filter(Boolean).join(', ')
    if (this.hasFloatingCardLocationTarget) {
      this.floatingCardLocationTarget.textContent = location
    }
    if (this.hasFloatingCardDatesTarget) {
      if (stay.wishlist || isDream) {
        this.floatingCardDatesTarget.textContent = 'Someday...'
        this.floatingCardDatesTarget.classList.add('italic', 'text-lavender')
      } else if (stay.check_in && stay.check_out) {
        const checkIn = new Date(stay.check_in).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        const checkOut = new Date(stay.check_out).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        this.floatingCardDatesTarget.textContent = `${checkIn} - ${checkOut}`
        this.floatingCardDatesTarget.classList.remove('italic', 'text-lavender')
      }
    }
    this.floatingCardTarget.classList.remove('hidden')
  }

  goToStayDetails() {
    if (this.selectedStay) {
      window.location.href = this.selectedStay.url
    }
  }

  toggleTimeline() {
    if (!this.hasTimelineTarget) return

    const panel = this.timelineTarget
    const isCollapsed = panel.dataset.collapsed === 'true'

    if (isCollapsed) {
      panel.classList.remove('-translate-x-full')
      panel.dataset.collapsed = 'false'
      if (this.hasCollapseIconTarget) {
        this.collapseIconTarget.classList.remove('rotate-180')
      }
      this.updateZoomControlPosition(false)
    } else {
      panel.classList.add('-translate-x-full')
      panel.dataset.collapsed = 'true'
      if (this.hasCollapseIconTarget) {
        this.collapseIconTarget.classList.add('rotate-180')
      }
      this.updateZoomControlPosition(true)
    }
  }

  togglePreviousStays() {
    this.previousStaysVisible = !this.previousStaysVisible

    // Toggle the list visibility
    if (this.hasPreviousStaysListTarget) {
      this.previousStaysListTarget.classList.toggle('hidden', !this.previousStaysVisible)
    }

    // Rotate the chevron
    if (this.hasPreviousStaysChevronTarget) {
      this.previousStaysChevronTarget.classList.toggle('rotate-180', this.previousStaysVisible)
    }

    // Toggle markers on the map
    this.previousStayMarkers.forEach(({ marker }) => {
      if (this.previousStaysVisible) {
        marker.addTo(this.map)
      } else {
        this.map.removeLayer(marker)
      }
    })
  }

  toggleDreamDestinations() {
    this.dreamDestinationsVisible = !this.dreamDestinationsVisible

    // Toggle the list visibility
    if (this.hasDreamDestinationsListTarget) {
      this.dreamDestinationsListTarget.classList.toggle('hidden', !this.dreamDestinationsVisible)
    }

    // Rotate the chevron
    if (this.hasDreamDestinationsChevronTarget) {
      this.dreamDestinationsChevronTarget.classList.toggle('rotate-180', this.dreamDestinationsVisible)
    }

    // Toggle markers on the map
    this.dreamDestinationMarkers.forEach(({ marker }) => {
      if (this.dreamDestinationsVisible) {
        marker.addTo(this.map)
      } else {
        this.map.removeLayer(marker)
      }
    })
  }

  togglePoi(event) {
    const category = event.currentTarget.dataset.category
    const button = event.currentTarget

    if (this.activeCategories.has(category)) {
      this.activeCategories.delete(category)
      button.classList.remove('active')
      this.removePOILayer(category)
    } else {
      this.activeCategories.add(category)
      button.classList.add('active')
      this.loadPOIs(category)
      this.searchViewportPOIs(category)
    }
  }

  async loadPOIs(category) {
    if (!this.stays || this.stays.length === 0) return

    // Cancel any in-flight requests for this category
    if (this.poiAbortControllers[category]) {
      this.poiAbortControllers[category].abort()
    }
    this.poiAbortControllers[category] = new AbortController()
    const signal = this.poiAbortControllers[category].signal

    // Create layer group if it doesn't exist
    if (!this.poiLayers[category]) {
      this.poiLayers[category] = L.layerGroup()
      this.poiLayers[category].addTo(this.map)
    }
    const layerGroup = this.poiLayers[category]

    // Filter stays to only those visible in viewport with valid coordinates
    const bounds = this.map.getBounds()
    const validStays = this.stays.filter(stay =>
      stay.latitude && stay.longitude &&
      bounds.contains(L.latLng(stay.latitude, stay.longitude))
    )

    // Filter out stays we've already fetched for this category
    const staysToFetch = validStays.filter(stay => {
      const key = `${category}-${stay.id}`
      return !this.fetchedPOIs[key]
    })

    if (staysToFetch.length === 0) return

    this.startLoading('poi', category)

    // Mark stays as fetched before starting requests
    staysToFetch.forEach(stay => {
      const key = `${category}-${stay.id}`
      this.fetchedPOIs[key] = true
    })

    try {
      // Fetch POIs for visible stays in parallel
      const fetchPromises = staysToFetch.map(stay => {
        const url = this.poisUrlValue.replace(':id', stay.id) + `?category=${category}`
        return fetch(url, { signal })
          .then(response => response.json())
          .then(pois => ({ stay, pois }))
          .catch(error => {
            if (error.name === 'AbortError') {
              // Request was cancelled, clear the fetched flag so it can be retried
              delete this.fetchedPOIs[`${category}-${stay.id}`]
              return null
            }
            console.error(`Failed to load POIs for stay ${stay.id}:`, error)
            return { stay, pois: [] }
          })
      })

      const results = await Promise.all(fetchPromises)

      // Check if this request was aborted
      if (signal.aborted) return

      // Render all POIs at once
      results.forEach(result => {
        if (!result) return // Skip aborted requests
        const { stay, pois } = result
        pois.forEach(poi => {
          if (poi.latitude && poi.longitude) {
            const icon = this.getPOIIcon(category)
            const marker = L.marker([poi.latitude, poi.longitude], { icon })
            const miles = (poi.distance_meters / 1609.34).toFixed(1)
            const distanceText = miles < 0.1 ? `${Math.round(miles * 5280)} ft` : `${miles} mi`
            marker.bindPopup(`
              <div class="poi-popup">
                <div class="poi-popup-header">
                  <span class="poi-popup-category ${category}">${this.getCategoryLabel(category)}</span>
                </div>
                <h4 class="poi-popup-name">${poi.name || 'Unknown'}</h4>
                <div class="poi-popup-details">
                  <span class="poi-popup-distance">${distanceText} away</span>
                  ${poi.address ? `<span class="poi-popup-address">${poi.address}</span>` : ''}
                  ${poi.opening_hours ? `<span class="poi-popup-hours">${poi.opening_hours}</span>` : ''}
                </div>
                <button
                  class="poi-popup-btn add-to-bucket-list-btn"
                  data-stay-id="${stay.id}"
                  data-poi-name="${(poi.name || '').replace(/"/g, '&quot;')}"
                  data-poi-address="${(poi.address || '').replace(/"/g, '&quot;')}"
                >
                  <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                  </svg>
                  Add to bucket list
                </button>
              </div>
            `, { className: 'cozy-popup', minWidth: 260, maxWidth: 300 })
          layerGroup.addLayer(marker)
        }
      })
    })
    } finally {
      this.stopLoading('poi', category)
    }
  }

  getPOIIcon(category) {
    const colors = {
      bus_stops: '#65a30d',
      stations: '#ef4444',
      coffee: '#92400e',
      grocery: '#f59e0b',
      gym: '#7c3aed',
      food: '#dc2626',
      coworking: '#0891b2',
      library: '#4f46e5',
      parks: '#059669'
    }

    return L.divIcon({
      className: 'poi-marker',
      html: `<div style="background-color: ${colors[category] || '#6b7280'}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white;"></div>`,
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })
  }

  getCategoryLabel(category) {
    const labels = {
      coffee: 'Coffee',
      food: 'Food & Dining',
      grocery: 'Grocery',
      gym: 'Fitness',
      library: 'Library',
      coworking: 'Coworking',
      bus_stops: 'Bus Stop',
      stations: 'Station',
      parks: 'Park'
    }
    return labels[category] || category
  }

  removePOILayer(category) {
    // Cancel any in-flight requests for this category
    if (this.poiAbortControllers[category]) {
      this.poiAbortControllers[category].abort()
      delete this.poiAbortControllers[category]
    }
    // Cancel any viewport search requests for this category
    if (this.viewportSearchAbortControllers[category]) {
      this.viewportSearchAbortControllers[category].abort()
      delete this.viewportSearchAbortControllers[category]
    }
    if (this.poiLayers[category]) {
      this.map.removeLayer(this.poiLayers[category])
      delete this.poiLayers[category]
    }
    // Clear fetched tracking for this category so re-enabling will fetch again
    Object.keys(this.fetchedPOIs).forEach(key => {
      if (key.startsWith(`${category}-`)) {
        delete this.fetchedPOIs[key]
      }
    })
    // Clear viewport search tracking for this category
    Object.keys(this.searchedGridCells).forEach(key => {
      if (key.startsWith(`${category}-`)) {
        delete this.searchedGridCells[key]
      }
    })
  }

  // Get grid key for viewport-based POI caching (matches backend logic)
  getGridKey(lat, lng, category) {
    const gridSize = 0.01 // ~1km grid cells
    const roundedLat = Math.floor(lat / gridSize) * gridSize
    const roundedLng = Math.floor(lng / gridSize) * gridSize
    return `${category}:${roundedLat.toFixed(2)}:${roundedLng.toFixed(2)}`
  }

  async searchViewportPOIs(category) {
    if (!this.hasPoisSearchUrlValue) return

    const center = this.map.getCenter()
    const gridKey = this.getGridKey(center.lat, center.lng, category)
    const trackingKey = `${category}-${gridKey}`

    // Skip if we've already searched this grid cell
    if (this.searchedGridCells[trackingKey]) return

    // Mark as searched before starting request
    this.searchedGridCells[trackingKey] = true

    // Cancel any in-flight viewport search for this category
    if (this.viewportSearchAbortControllers[category]) {
      this.viewportSearchAbortControllers[category].abort()
    }
    this.viewportSearchAbortControllers[category] = new AbortController()
    const signal = this.viewportSearchAbortControllers[category].signal

    // Create layer group if it doesn't exist
    if (!this.poiLayers[category]) {
      this.poiLayers[category] = L.layerGroup()
      this.poiLayers[category].addTo(this.map)
    }
    const layerGroup = this.poiLayers[category]

    this.startLoading('poi', category)

    try {
      const url = `${this.poisSearchUrlValue}?lat=${center.lat}&lng=${center.lng}&category=${category}`
      const response = await fetch(url, { signal })
      const pois = await response.json()

      if (signal.aborted) return

      pois.forEach(poi => {
        if (poi.latitude && poi.longitude) {
          const icon = this.getPOIIcon(category)
          const marker = L.marker([poi.latitude, poi.longitude], { icon })

          // Find nearest stay to this POI for bucket list button
          const nearestStay = this.findNearestStay(poi.latitude, poi.longitude)
          const stayId = nearestStay ? nearestStay.id : null

          marker.bindPopup(`
            <div class="poi-popup">
              <div class="poi-popup-header">
                <span class="poi-popup-category ${category}">${this.getCategoryLabel(category)}</span>
              </div>
              <h4 class="poi-popup-name">${poi.name || 'Unknown'}</h4>
              <div class="poi-popup-details">
                ${poi.address ? `<span class="poi-popup-address">${poi.address}</span>` : ''}
                ${poi.opening_hours ? `<span class="poi-popup-hours">${poi.opening_hours}</span>` : ''}
              </div>
              ${stayId ? `
                <button
                  class="poi-popup-btn add-to-bucket-list-btn"
                  data-stay-id="${stayId}"
                  data-poi-name="${(poi.name || '').replace(/"/g, '&quot;')}"
                  data-poi-address="${(poi.address || '').replace(/"/g, '&quot;')}"
                >
                  <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                  </svg>
                  Add to bucket list
                </button>
              ` : ''}
            </div>
          `, { className: 'cozy-popup', minWidth: 260, maxWidth: 300 })
          layerGroup.addLayer(marker)
        }
      })
    } catch (error) {
      if (error.name === 'AbortError') {
        // Request was cancelled, clear the searched flag so it can be retried
        delete this.searchedGridCells[trackingKey]
        return
      }
      console.error(`Failed to search viewport POIs for ${category}:`, error)
    } finally {
      this.stopLoading('poi', category)
    }
  }

  toggleTransit(event) {
    const routeType = event.currentTarget.dataset.routeType
    const button = event.currentTarget

    if (this.activeTransitTypes.has(routeType)) {
      this.activeTransitTypes.delete(routeType)
      button.classList.remove('active')
      this.removeTransitLayer(routeType)
    } else {
      this.activeTransitTypes.add(routeType)
      button.classList.add('active')
      this.loadTransitRoutes(routeType)
    }
  }

  async loadTransitRoutes(routeType) {
    if (!this.stays || this.stays.length === 0) return

    // Cancel any in-flight requests for this route type
    if (this.transitAbortControllers[routeType]) {
      this.transitAbortControllers[routeType].abort()
    }
    this.transitAbortControllers[routeType] = new AbortController()
    const signal = this.transitAbortControllers[routeType].signal

    // Create layer group if it doesn't exist
    if (!this.transitLayers[routeType]) {
      this.transitLayers[routeType] = L.layerGroup()
      this.transitLayers[routeType].addTo(this.map)
    }
    const layerGroup = this.transitLayers[routeType]

    // Filter stays to only those visible in viewport with valid coordinates
    const bounds = this.map.getBounds()
    const validStays = this.stays.filter(stay =>
      stay.latitude && stay.longitude &&
      bounds.contains(L.latLng(stay.latitude, stay.longitude))
    )

    // Filter out stays we've already fetched for this route type
    const staysToFetch = validStays.filter(stay => {
      const key = `${routeType}-${stay.id}`
      return !this.fetchedTransit[key]
    })

    if (staysToFetch.length === 0) return

    this.startLoading('transit', routeType)

    // Mark stays as fetched before starting requests
    staysToFetch.forEach(stay => {
      const key = `${routeType}-${stay.id}`
      this.fetchedTransit[key] = true
    })

    try {
      // Fetch transit routes for visible stays in parallel
      const fetchPromises = staysToFetch.map(stay => {
        const url = this.transitUrlValue.replace(':id', stay.id) + `?route_type=${routeType}`
        return fetch(url, { signal })
          .then(response => response.json())
          .then(routes => ({ stay, routes }))
          .catch(error => {
            if (error.name === 'AbortError') {
              // Request was cancelled, clear the fetched flag so it can be retried
              delete this.fetchedTransit[`${routeType}-${stay.id}`]
              return null
            }
            console.error(`Failed to load transit routes for stay ${stay.id}:`, error)
            return { stay, routes: [] }
          })
      })

      const results = await Promise.all(fetchPromises)

      // Check if this request was aborted
      if (signal.aborted) return

      // Render all routes at once
      results.forEach(result => {
        if (!result) return // Skip aborted requests
        const { routes } = result
        routes.forEach(route => {
          if (route.geometry && route.geometry.length > 0) {
            const style = this.getTransitStyle(routeType, route.color)

            // geometry is array of paths - each path is array of [lat, lng] points
            route.geometry.forEach(path => {
              if (path && path.length >= 2) {
                const polyline = L.polyline(path, style)
                polyline.bindPopup(`
                  <div class="p-1">
                    <strong>${route.name || routeType.charAt(0).toUpperCase() + routeType.slice(1)} Line</strong>
                  </div>
                `)
                layerGroup.addLayer(polyline)
              }
            })
          }
        })
      })
    } finally {
      this.stopLoading('transit', routeType)
    }
  }

  getTransitStyle(routeType, routeColor) {
    const defaults = {
      rails: { color: '#e11d48', weight: 4, opacity: 0.8 },
      train: { color: '#1d4ed8', weight: 5, opacity: 0.8 },
      ferry: { color: '#0284c7', weight: 4, opacity: 0.7 },
      bus: { color: '#65a30d', weight: 3, opacity: 0.6 }
    }

    const style = defaults[routeType] || { color: '#6b7280', weight: 3, opacity: 0.6 }
    if (routeColor) {
      style.color = routeColor.startsWith('#') ? routeColor : `#${routeColor}`
    }
    return style
  }

  removeTransitLayer(routeType) {
    // Cancel any in-flight requests for this route type
    if (this.transitAbortControllers[routeType]) {
      this.transitAbortControllers[routeType].abort()
      delete this.transitAbortControllers[routeType]
    }
    if (this.transitLayers[routeType]) {
      this.map.removeLayer(this.transitLayers[routeType])
      delete this.transitLayers[routeType]
    }
    // Clear fetched tracking for this route type so re-enabling will fetch again
    Object.keys(this.fetchedTransit).forEach(key => {
      if (key.startsWith(`${routeType}-`)) {
        delete this.fetchedTransit[key]
      }
    })
  }

  toggleBucketList(event) {
    const button = event.currentTarget

    if (this.bucketListVisible) {
      this.bucketListVisible = false
      button.classList.remove('active')
      this.removeBucketListLayer()
    } else {
      this.bucketListVisible = true
      button.classList.add('active')
      this.loadBucketListItems()
    }
  }

  async loadBucketListItems() {
    if (this.bucketListItems) {
      this.renderBucketListMarkers()
      return
    }

    const button = this.element.querySelector('[data-action="click->map#toggleBucketList"]')
    if (button) button.classList.add('loading')

    try {
      const response = await fetch(this.bucketListUrlValue)
      this.bucketListItems = await response.json()
      this.renderBucketListMarkers()
    } catch (error) {
      console.error('Failed to load bucket list items:', error)
    } finally {
      if (button) button.classList.remove('loading')
    }
  }

  renderBucketListMarkers() {
    this.removeBucketListLayer()

    if (!this.bucketListItems || this.bucketListItems.length === 0) return

    this.bucketListLayer = L.layerGroup()

    this.bucketListItems.forEach(item => {
      const icon = this.getBucketListIcon(item.completed)
      const marker = L.marker([item.latitude, item.longitude], { icon })
      marker.bindPopup(this.getBucketListPopupContent(item), { className: 'cozy-popup', minWidth: 200, maxWidth: 280 })
      this.bucketListLayer.addLayer(marker)
    })

    this.bucketListLayer.addTo(this.map)
  }

  getBucketListIcon(completed) {
    const color = completed ? '#9ca3af' : '#ec4899' // gray if completed, pink if not
    return L.divIcon({
      className: 'custom-div-icon',
      html: `<div style="background-color: ${color}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>`,
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })
  }

  getBucketListPopupContent(item) {
    const badgeClass = item.completed ? 'bg-gray-100 text-gray-700' : 'bg-pink-100 text-pink-700'
    const badgeText = item.completed ? 'Completed' : 'Bucket List'
    return `
      <div class="poi-popup">
        <div class="poi-popup-header">
          <span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full ${badgeClass}">${badgeText}</span>
        </div>
        <h4 class="poi-popup-name">${item.title}</h4>
        <div class="poi-popup-details">
          ${item.address ? `<span class="poi-popup-address">${item.address}</span>` : ''}
          <span class="text-xs text-brown-light">From: ${item.stay_title}</span>
        </div>
      </div>
    `
  }

  removeBucketListLayer() {
    if (this.bucketListLayer) {
      this.map.removeLayer(this.bucketListLayer)
      this.bucketListLayer = null
    }
  }

  findNearestStay(lat, lng) {
    if (!this.stays || this.stays.length === 0) return null

    let nearest = null
    let minDistance = Infinity

    this.stays.forEach(stay => {
      if (stay.latitude && stay.longitude) {
        const distance = this.calculateDistance(lat, lng, stay.latitude, stay.longitude)
        if (distance < minDistance) {
          minDistance = distance
          nearest = stay
        }
      }
    })

    return nearest
  }

  calculateDistance(lat1, lng1, lat2, lng2) {
    // Simple Euclidean distance (good enough for nearby comparisons)
    const dLat = lat2 - lat1
    const dLng = lng2 - lng1
    return Math.sqrt(dLat * dLat + dLng * dLng)
  }

  disconnect() {
    if (this.bucketListClickHandler) {
      document.removeEventListener('click', this.bucketListClickHandler)
    }
    if (this.map) {
      this.map.remove()
    }
  }
}
