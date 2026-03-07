import { Controller } from "@hotwired/stimulus"

const COTTAGECORE_COLORS = [
  "#B8C9B8", // sage
  "#D4A5A5", // rose
  "#C8BFD4", // lavender
  "#C9B8A8", // taupe
  "#E8B4A0", // coral
]

const UNVISITED_COLOR = "#d4d4d4"
const BORDER_COLOR = "#5D4E4E"

export default class extends Controller {
  static targets = ["map", "panel", "panelTitle", "panelSubtitle", "panelContent", "statsText", "progressBar"]
  static values = { apiUrl: String, geojsonUrl: String, newStayUrl: String }

  connect() {
    this.stateData = {}
    this.panelOpen = false
    this.initMap()
    this.loadData()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initMap() {
    const L = window.L
    this.map = L.map(this.mapTarget, {
      center: [39.8, -98.5],
      zoom: 4,
      minZoom: 3,
      maxZoom: 8,
      zoomControl: true,
      attributionControl: true
    })

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      opacity: 0.3
    }).addTo(this.map)
  }

  async loadData() {
    try {
      const [apiResponse, geoResponse] = await Promise.all([
        fetch(this.apiUrlValue, { credentials: "same-origin" }),
        fetch(this.geojsonUrlValue)
      ])

      const apiData = await apiResponse.json()
      const geoJson = await geoResponse.json()

      this.stateData = apiData.states || {}
      this.updateStats(apiData.total_visited, apiData.total_states)
      this.renderStates(geoJson)
    } catch (error) {
      console.error("Failed to load scratch map data:", error)
    }
  }

  updateStats(visited, total) {
    if (this.hasStatsTextTarget) {
      this.statsTextTarget.textContent = `${visited} of ${total} states explored`
    }
    if (this.hasProgressBarTarget) {
      const pct = total > 0 ? (visited / total) * 100 : 0
      this.progressBarTarget.style.width = `${pct}%`
    }
  }

  renderStates(geoJson) {
    const L = window.L
    const visited = this.stateData

    this.geojsonLayer = L.geoJSON(geoJson, {
      style: (feature) => this.styleState(feature),
      onEachFeature: (feature, layer) => {
        const name = feature.properties.name
        const isVisited = !!visited[name]

        // Hover effects
        layer.on("mouseover", () => {
          layer.setStyle({
            weight: 2,
            fillOpacity: isVisited ? 0.75 : 0.55
          })
        })
        layer.on("mouseout", () => {
          layer.setStyle(this.styleState(feature))
        })

        // Click handler
        layer.on("click", () => {
          if (isVisited) {
            this.showVisitedPanel(name, visited[name])
          } else {
            this.showUnvisitedPanel(name)
          }
        })
      }
    }).addTo(this.map)

    // Add visit count badges on visited states
    this.addCountBadges(geoJson, visited)
  }

  styleState(feature) {
    const name = feature.properties.name
    const isVisited = !!this.stateData[name]

    if (isVisited) {
      // Cycle through cottagecore colors by hashing state name
      const colorIndex = this.hashString(name) % COTTAGECORE_COLORS.length
      return {
        fillColor: COTTAGECORE_COLORS[colorIndex],
        fillOpacity: 0.6,
        color: BORDER_COLOR,
        weight: 1,
        dashArray: ""
      }
    } else {
      return {
        fillColor: UNVISITED_COLOR,
        fillOpacity: 0.4,
        color: BORDER_COLOR,
        weight: 0.5,
        dashArray: "3 3"
      }
    }
  }

  addCountBadges(geoJson, visited) {
    const L = window.L

    geoJson.features.forEach((feature) => {
      const name = feature.properties.name
      if (!visited[name]) return

      // Compute centroid from bounds of the feature
      const layer = L.geoJSON(feature)
      const center = layer.getBounds().getCenter()

      const count = visited[name].count
      const icon = L.divIcon({
        className: "scratch-badge",
        html: `<span class="scratch-badge-inner">${count}</span>`,
        iconSize: [28, 28],
        iconAnchor: [14, 14]
      })

      L.marker(center, { icon, interactive: false }).addTo(this.map)
    })
  }

  showVisitedPanel(stateName, data) {
    this.panelTitleTarget.textContent = stateName
    this.panelSubtitleTarget.textContent = `${data.count} ${data.count === 1 ? "stay" : "stays"}`

    let html = ""
    data.stays.forEach((stay) => {
      const dates = this.formatDates(stay.check_in, stay.check_out)
      const imgHtml = stay.image_url
        ? `<img src="${this.escapeHtml(stay.image_url)}" alt="" class="w-16 h-16 rounded-xl object-cover flex-shrink-0">`
        : `<div class="w-16 h-16 rounded-xl bg-taupe-light flex items-center justify-center flex-shrink-0">
             <svg class="w-6 h-6 text-taupe" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"></path>
             </svg>
           </div>`

      html += `
        <a href="/stays/${stay.id}" class="cozy-card flex items-center gap-3 p-3 hover:shadow-cozy transition-shadow" data-turbo-frame="_top">
          ${imgHtml}
          <div class="flex-1 min-w-0">
            <p class="font-semibold text-brown text-sm truncate">${this.escapeHtml(stay.title)}</p>
            <p class="text-xs text-brown-light">${this.escapeHtml(stay.city || "")}</p>
            <p class="text-xs text-brown-light mt-1">${dates}</p>
            ${stay.duration_days ? `<span class="text-xs text-sage-dark">${stay.duration_days} nights</span>` : ""}
          </div>
          <svg class="w-4 h-4 text-taupe flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </a>`
    })

    this.panelContentTarget.innerHTML = html
    this.openPanel()
  }

  showUnvisitedPanel(stateName) {
    this.panelTitleTarget.textContent = stateName
    this.panelSubtitleTarget.textContent = "Not yet explored"

    const newStayUrl = `${this.newStayUrlValue}?state=${encodeURIComponent(stateName)}`
    this.panelContentTarget.innerHTML = `
      <div class="text-center py-6">
        <div class="w-16 h-16 mx-auto mb-4 rounded-full bg-lavender-light flex items-center justify-center">
          <svg class="w-8 h-8 text-lavender-dark" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
          </svg>
        </div>
        <p class="text-brown-light text-sm mb-4">You haven't explored ${this.escapeHtml(stateName)} yet.</p>
        <a href="${newStayUrl}" class="btn-primary inline-flex items-center gap-2 px-4 py-2 text-sm">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          Add to dream destinations
        </a>
      </div>`

    this.openPanel()
  }

  openPanel() {
    this.panelOpen = true
    // Mobile: translate-y-0 (slide up), Desktop: translate-x-0 (slide in from right)
    this.panelTarget.classList.remove("translate-y-full", "sm:translate-x-full")
    this.panelTarget.classList.add("translate-y-0", "sm:translate-x-0")
  }

  closePanel() {
    this.panelOpen = false
    this.panelTarget.classList.remove("translate-y-0", "sm:translate-x-0")
    this.panelTarget.classList.add("translate-y-full", "sm:translate-x-full")
  }

  formatDates(checkIn, checkOut) {
    if (!checkIn || !checkOut) return ""
    const opts = { month: "short", day: "numeric", year: "numeric" }
    const start = new Date(checkIn + "T00:00:00").toLocaleDateString("en-US", opts)
    const end = new Date(checkOut + "T00:00:00").toLocaleDateString("en-US", opts)
    return `${start} — ${end}`
  }

  hashString(str) {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i)
      hash |= 0
    }
    return Math.abs(hash)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
