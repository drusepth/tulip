import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]
  static values = {
    stayId: Number
  }

  connect() {
    this.currentCategory = null
  }

  async loadCategory(event) {
    const category = event.params.category
    const button = event.currentTarget

    // If clicking the same category, toggle it off
    if (this.currentCategory === category) {
      this.element.querySelectorAll('.category-pill').forEach(b => b.classList.remove('active'))
      this.resultsTarget.classList.add('hidden')
      this.resultsTarget.innerHTML = ''
      this.currentCategory = null
      return
    }

    // Toggle active state on buttons
    this.element.querySelectorAll('.category-pill').forEach(b => b.classList.remove('active'))
    button.classList.add('active')
    this.currentCategory = category

    // Show loading state
    this.resultsTarget.innerHTML = '<p class="text-sm text-brown-light py-2">Loading nearby places...</p>'
    this.resultsTarget.classList.remove('hidden')

    try {
      // Fetch POIs for this category
      const response = await fetch(`/api/stays/${this.stayIdValue}/pois?category=${category}`)
      const pois = await response.json()

      this.renderResults(pois, category)
    } catch (error) {
      console.error('Failed to fetch POIs:', error)
      this.resultsTarget.innerHTML = '<p class="text-sm text-rose-dark py-2">Failed to load places. Please try again.</p>'
    }
  }

  renderResults(pois, category) {
    if (pois.length === 0) {
      this.resultsTarget.innerHTML = '<p class="text-sm text-brown-light py-2">No places found nearby</p>'
      return
    }

    // Render compact POI list with add buttons (limit to 8)
    const html = pois.slice(0, 8).map(poi => `
      <div class="flex items-center justify-between py-2 border-b border-taupe-light last:border-0">
        <div class="flex-1 min-w-0">
          <p class="text-sm text-brown font-medium truncate">${this.escapeHtml(poi.name || 'Unnamed')}</p>
          <p class="text-xs text-brown-light">${this.formatDistance(poi.distance_meters)}</p>
        </div>
        <button type="button"
                class="poi-add-btn ml-2 w-7 h-7 flex items-center justify-center rounded-full bg-sage-light hover:bg-sage text-sage-dark hover:text-white transition-colors cursor-pointer"
                data-action="click->poi-category-picker#addToBucketList"
                data-poi-category-picker-poi-param='${this.escapeJsonAttr(poi)}'>
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
        </button>
      </div>
    `).join('')

    this.resultsTarget.innerHTML = `
      <div class="bg-cream rounded-xl p-3 max-h-64 overflow-y-auto">
        ${html}
      </div>
    `
  }

  async addToBucketList(event) {
    const poi = event.params.poi
    const button = event.currentTarget

    // Disable button and show loading
    button.disabled = true
    button.innerHTML = '<span class="text-xs">...</span>'

    try {
      // Submit to bucket list
      const formData = new FormData()
      formData.append('bucket_list_item[title]', poi.name || 'Unnamed Place')
      formData.append('bucket_list_item[address]', poi.address || '')
      formData.append('source_poi_id', poi.id)
      formData.append('compact', 'true')

      const response = await fetch(`/stays/${this.stayIdValue}/bucket_list_items`, {
        method: 'POST',
        body: formData,
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        // Process turbo stream response
        const html = await response.text()
        Turbo.renderStreamMessage(html)

        // Update button to show added state
        button.innerHTML = `
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        `
        button.classList.remove('bg-sage-light', 'hover:bg-sage', 'text-sage-dark', 'hover:text-white')
        button.classList.add('bg-sage', 'text-white')
      } else {
        // Reset button on error
        button.disabled = false
        button.innerHTML = `
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
        `
      }
    } catch (error) {
      console.error('Failed to add to bucket list:', error)
      // Reset button on error
      button.disabled = false
      button.innerHTML = `
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        </svg>
      `
    }
  }

  formatDistance(meters) {
    if (!meters) return ''
    const miles = meters / 1609.34
    if (miles < 0.1) {
      return `${Math.round(miles * 5280)} ft`
    }
    return `${miles.toFixed(1)} mi`
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  escapeJsonAttr(obj) {
    return JSON.stringify(obj)
      .replace(/&/g, '&amp;')
      .replace(/'/g, '&#39;')
      .replace(/"/g, '&quot;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
  }
}
