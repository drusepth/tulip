import { Controller } from "@hotwired/stimulus"
// Leaflet is loaded globally via CDN in application.html.erb

export default class extends Controller {
  static targets = ["container", "timeline", "staysList", "collapseIcon"]
  static values = {
    staysUrl: String,
    poisUrl: String,
    transitUrl: String,
    poisSearchUrl: String
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
    this.poiAbortControllers = {}    // AbortControllers for in-flight POI requests
    this.transitAbortControllers = {} // AbortControllers for in-flight transit requests
    this.searchedGridCells = {}      // Track searched viewport grid cells by `${category}-${gridKey}`
    this.viewportSearchAbortControllers = {} // AbortControllers for viewport POI searches
    this.viewportChangeTimeout = null // Debounce timeout for viewport changes
    this.loadingCounts = {}    // Track in-flight request counts per category/routeType

    // Auto-load POIs/transit when viewport changes
    this.map.on('moveend', () => this.onViewportChange())
  }

  // Loading state helpers
  startLoading(type, key) {
    const loadingKey = `${type}-${key}`
    this.loadingCounts[loadingKey] = (this.loadingCounts[loadingKey] || 0) + 1
    const button = this.element.querySelector(`[data-${type === 'poi' ? 'category' : 'route-type'}="${key}"]`)
    if (button) button.classList.add('loading')
  }

  stopLoading(type, key) {
    const loadingKey = `${type}-${key}`
    this.loadingCounts[loadingKey] = Math.max(0, (this.loadingCounts[loadingKey] || 1) - 1)
    if (this.loadingCounts[loadingKey] === 0) {
      const button = this.element.querySelector(`[data-${type === 'poi' ? 'category' : 'route-type'}="${key}"]`)
      if (button) button.classList.remove('loading')
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
    } catch (error) {
      console.error('Failed to load stays:', error)
    }
  }

  renderStayMarkers(stays) {
    const bounds = []

    stays.forEach(stay => {
      if (stay.latitude && stay.longitude) {
        const color = this.getStatusColor(stay.status)
        const marker = L.circleMarker([stay.latitude, stay.longitude], {
          radius: 10,
          fillColor: color,
          color: '#fff',
          weight: 2,
          opacity: 1,
          fillOpacity: 0.8
        })

        const statusBadge = stay.booked
          ? `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-green-100 text-green-800">Booked</span>`
          : `<span class="inline-block px-2 py-0.5 text-xs font-medium rounded-full bg-purple-100 text-purple-800">Planned</span>`

        const imageHtml = stay.image_url
          ? `<div class="popup-image">
               <img src="${stay.image_url}" alt="${stay.title}"/>
             </div>`
          : ''

        const checkIn = new Date(stay.check_in).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        const checkOut = new Date(stay.check_out).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

        marker.bindPopup(`
          <div class="popup-content">
            ${imageHtml}
            <div class="popup-body">
              <div class="popup-badges">
                ${statusBadge}
                <span class="popup-nights">${stay.duration_days} nights</span>
              </div>
              <h3 class="popup-title">${stay.title}</h3>
              <p class="popup-dates">${checkIn} - ${checkOut}</p>
              <a href="${stay.url}" class="popup-link">
                View Details
                <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                </svg>
              </a>
            </div>
          </div>
        `, { className: 'cozy-popup', maxWidth: 260 })

        marker.addTo(this.map)
        this.stayMarkers.push({ marker, stay })
        bounds.push([stay.latitude, stay.longitude])
      }
    })

    if (bounds.length > 0) {
      this.map.fitBounds(bounds, { padding: [50, 50] })
    }
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
    if (!this.hasStaysListTarget) return

    // Sort by check_in date
    const sorted = [...stays].sort((a, b) => new Date(a.check_in) - new Date(b.check_in))

    // Render each stay as a clickable card
    this.staysListTarget.innerHTML = sorted.map(stay => {
      const color = this.getStatusColor(stay.status)
      const checkIn = new Date(stay.check_in).toLocaleDateString()
      const checkOut = new Date(stay.check_out).toLocaleDateString()
      const location = [stay.city, stay.country].filter(Boolean).join(', ')

      return `
        <button data-action="click->map#zoomToStay" data-stay-id="${stay.id}"
                class="w-full text-left p-3 rounded-lg hover:bg-gray-100 border border-gray-200 transition-colors">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full flex-shrink-0" style="background-color: ${color}"></span>
            <div class="font-medium text-gray-900 truncate">${stay.title}</div>
          </div>
          <div class="text-sm text-gray-500 mt-1 ml-5">${location}</div>
          <div class="text-xs text-gray-400 mt-1 ml-5">${checkIn} - ${checkOut}</div>
        </button>
      `
    }).join('')
  }

  zoomToStay(event) {
    const stayId = event.currentTarget.dataset.stayId
    const stay = this.stays.find(s => s.id == stayId)
    if (stay && stay.latitude && stay.longitude) {
      this.map.setView([stay.latitude, stay.longitude], 14, { animate: true })
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
        const { pois } = result
        pois.forEach(poi => {
          if (poi.latitude && poi.longitude) {
            const icon = this.getPOIIcon(category)
            const marker = L.marker([poi.latitude, poi.longitude], { icon })
            marker.bindPopup(`
              <div class="p-1">
                <strong>${poi.name || 'Unknown'}</strong>
                <br><span class="text-sm text-gray-500">${poi.distance_meters}m from stay</span>
                ${poi.opening_hours ? `<br><span class="text-xs">${poi.opening_hours}</span>` : ''}
              </div>
            `)
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
      library: '#4f46e5'
    }

    return L.divIcon({
      className: 'poi-marker',
      html: `<div style="background-color: ${colors[category] || '#6b7280'}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white;"></div>`,
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })
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
          marker.bindPopup(`
            <div class="p-1">
              <strong>${poi.name || 'Unknown'}</strong>
              ${poi.address ? `<br><span class="text-sm text-gray-500">${poi.address}</span>` : ''}
              ${poi.opening_hours ? `<br><span class="text-xs">${poi.opening_hours}</span>` : ''}
            </div>
          `)
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

            // geometry is now array of paths - render each as separate polyline
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

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
