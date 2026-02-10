import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    poiLat: Number,
    poiLng: Number,
    poiName: String,
    stayLat: Number,
    stayLng: Number,
    stayName: String
  }

  connect() {
    this.initializeMap()
  }

  initializeMap() {
    const bounds = L.latLngBounds(
      [this.poiLatValue, this.poiLngValue],
      [this.stayLatValue, this.stayLngValue]
    )

    this.map = L.map(this.element, {
      scrollWheelZoom: false,
      dragging: true,
      zoomControl: true
    }).fitBounds(bounds, { padding: [40, 40], maxZoom: 16 })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map)

    // POI marker (default blue)
    L.marker([this.poiLatValue, this.poiLngValue])
      .addTo(this.map)
      .bindPopup(this.poiNameValue)
      .openPopup()

    // Stay marker (custom sage color)
    const stayIcon = L.divIcon({
      className: 'stay-map-marker',
      html: `<div style="width:12px;height:12px;background:#8FA68F;border:2px solid white;border-radius:50%;box-shadow:0 2px 4px rgba(0,0,0,0.3);"></div>`,
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    })

    L.marker([this.stayLatValue, this.stayLngValue], { icon: stayIcon })
      .addTo(this.map)
      .bindPopup(`<span style="font-size:13px;">Your stay: ${this.stayNameValue}</span>`)

    // Dashed line connecting them
    L.polyline(
      [[this.poiLatValue, this.poiLngValue], [this.stayLatValue, this.stayLngValue]],
      { color: '#C9B8A8', weight: 2, dashArray: '6, 8', opacity: 0.7 }
    ).addTo(this.map)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
