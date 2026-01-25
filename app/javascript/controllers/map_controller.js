import { Controller } from "@hotwired/stimulus"
// Leaflet is loaded globally via CDN in application.html.erb

export default class extends Controller {
  static targets = ["container"]
  static values = {
    staysUrl: String,
    poisUrl: String,
    transitUrl: String
  }

  connect() {
    this.initializeMap()
    this.loadStays()
    this.poiLayers = {}
    this.transitLayers = {}
    this.activeCategories = new Set()
    this.activeTransitTypes = new Set()
    this.stayMarkers = []
  }

  initializeMap() {
    const mapElement = this.hasContainerTarget ? this.containerTarget : this.element
    this.map = L.map(mapElement).setView([20, 0], 2)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)
  }

  async loadStays() {
    try {
      const response = await fetch(this.staysUrlValue)
      const stays = await response.json()
      this.stays = stays
      this.renderStayMarkers(stays)
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

        marker.bindPopup(`
          <div class="p-2">
            <h3 class="font-bold text-lg">${stay.title}</h3>
            <p class="text-gray-600">${[stay.city, stay.country].filter(Boolean).join(', ')}</p>
            <p class="text-sm text-gray-500 mt-1">
              ${new Date(stay.check_in).toLocaleDateString()} - ${new Date(stay.check_out).toLocaleDateString()}
            </p>
            <a href="${stay.url}" class="inline-block mt-2 text-indigo-600 hover:text-indigo-800">
              View Details &rarr;
            </a>
          </div>
        `)

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

  togglePoi(event) {
    const category = event.currentTarget.dataset.category
    const button = event.currentTarget

    if (this.activeCategories.has(category)) {
      this.activeCategories.delete(category)
      button.classList.remove('bg-indigo-600', 'text-white')
      button.classList.add('bg-white', 'text-gray-700')
      this.removePOILayer(category)
    } else {
      this.activeCategories.add(category)
      button.classList.add('bg-indigo-600', 'text-white')
      button.classList.remove('bg-white', 'text-gray-700')
      this.loadPOIs(category)
    }
  }

  async loadPOIs(category) {
    if (!this.stays || this.stays.length === 0) return

    const layerGroup = L.layerGroup()
    this.poiLayers[category] = layerGroup

    for (const stay of this.stays) {
      if (!stay.latitude || !stay.longitude) continue

      try {
        const url = this.poisUrlValue.replace(':id', stay.id) + `?category=${category}`
        const response = await fetch(url)
        const pois = await response.json()

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
      } catch (error) {
        console.error(`Failed to load POIs for stay ${stay.id}:`, error)
      }
    }

    layerGroup.addTo(this.map)
  }

  getPOIIcon(category) {
    const colors = {
      transit_stops: '#ef4444',
      coffee: '#92400e',
      veterinarian: '#10b981',
      grocery: '#f59e0b'
    }

    return L.divIcon({
      className: 'poi-marker',
      html: `<div style="background-color: ${colors[category] || '#6b7280'}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white;"></div>`,
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })
  }

  removePOILayer(category) {
    if (this.poiLayers[category]) {
      this.map.removeLayer(this.poiLayers[category])
      delete this.poiLayers[category]
    }
  }

  toggleTransit(event) {
    const routeType = event.currentTarget.dataset.routeType
    const button = event.currentTarget

    if (this.activeTransitTypes.has(routeType)) {
      this.activeTransitTypes.delete(routeType)
      button.classList.remove('bg-indigo-600', 'text-white')
      button.classList.add('bg-white', 'text-gray-700')
      this.removeTransitLayer(routeType)
    } else {
      this.activeTransitTypes.add(routeType)
      button.classList.add('bg-indigo-600', 'text-white')
      button.classList.remove('bg-white', 'text-gray-700')
      this.loadTransitRoutes(routeType)
    }
  }

  async loadTransitRoutes(routeType) {
    if (!this.stays || this.stays.length === 0) return

    const layerGroup = L.layerGroup()
    this.transitLayers[routeType] = layerGroup

    for (const stay of this.stays) {
      if (!stay.latitude || !stay.longitude) continue

      try {
        const url = this.transitUrlValue.replace(':id', stay.id) + `?route_type=${routeType}`
        const response = await fetch(url)
        const routes = await response.json()

        routes.forEach(route => {
          if (route.geometry && route.geometry.length > 0) {
            const style = this.getTransitStyle(routeType, route.color)
            const polyline = L.polyline(route.geometry, style)
            polyline.bindPopup(`
              <div class="p-1">
                <strong>${route.name || routeType.charAt(0).toUpperCase() + routeType.slice(1)} Line</strong>
              </div>
            `)
            layerGroup.addLayer(polyline)
          }
        })
      } catch (error) {
        console.error(`Failed to load transit routes for stay ${stay.id}:`, error)
      }
    }

    layerGroup.addTo(this.map)
  }

  getTransitStyle(routeType, routeColor) {
    const defaults = {
      subway: { color: '#e11d48', weight: 5, opacity: 0.8 },
      tram: { color: '#0891b2', weight: 4, opacity: 0.7 },
      bus: { color: '#65a30d', weight: 3, opacity: 0.6 }
    }

    const style = defaults[routeType] || { color: '#6b7280', weight: 3, opacity: 0.6 }
    if (routeColor) {
      style.color = routeColor.startsWith('#') ? routeColor : `#${routeColor}`
    }
    return style
  }

  removeTransitLayer(routeType) {
    if (this.transitLayers[routeType]) {
      this.map.removeLayer(this.transitLayers[routeType])
      delete this.transitLayers[routeType]
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
