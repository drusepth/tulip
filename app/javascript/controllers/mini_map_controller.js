import { Controller } from "@hotwired/stimulus"
// Leaflet is loaded globally via CDN in application.html.erb

export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    title: String
  }

  connect() {
    this.initializeMap()
  }

  initializeMap() {
    this.map = L.map(this.element, {
      scrollWheelZoom: false,
      dragging: true,
      zoomControl: true
    }).setView([this.latValue, this.lngValue], 15)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map)

    L.marker([this.latValue, this.lngValue])
      .addTo(this.map)
      .bindPopup(this.titleValue)
      .openPopup()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
