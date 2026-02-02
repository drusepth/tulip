import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "fab", "group"]

  connect() {
    this.loadPreferences()
    this.setupEventListeners()
  }

  loadPreferences() {
    // Load panel open/closed state
    const panelOpen = localStorage.getItem('tulip-layers-panel-open')
    if (panelOpen === 'false') {
      this.closePanel()
    } else {
      this.openPanel()
    }

    // Load collapsed group states
    this.groupTargets.forEach(group => {
      const groupId = group.dataset.groupId
      const collapsed = localStorage.getItem(`tulip-layers-group-${groupId}`)
      if (collapsed === 'true') {
        this.collapseGroup(group)
      }
    })

    // Load active layer states and dispatch events to activate them
    const activeCategories = JSON.parse(localStorage.getItem('tulip-active-categories') || '[]')
    const activeTransitTypes = JSON.parse(localStorage.getItem('tulip-active-transit-types') || '[]')
    const bucketListActive = localStorage.getItem('tulip-bucket-list-active') === 'true'

    // Delay to ensure map controller is connected
    setTimeout(() => {
      activeCategories.forEach(category => {
        const toggle = this.element.querySelector(`[data-layer-type="poi"][data-category="${category}"]`)
        if (toggle) {
          toggle.classList.add('active')
          this.dispatchLayerEvent('poi', category, true)
        }
      })

      activeTransitTypes.forEach(routeType => {
        const toggle = this.element.querySelector(`[data-layer-type="transit"][data-route-type="${routeType}"]`)
        if (toggle) {
          toggle.classList.add('active')
          this.dispatchLayerEvent('transit', routeType, true)
        }
      })

      if (bucketListActive) {
        const toggle = this.element.querySelector('[data-layer-type="bucket-list"]')
        if (toggle) {
          toggle.classList.add('active')
          this.dispatchLayerEvent('bucket-list', null, true)
        }
      }
    }, 100)
  }

  setupEventListeners() {
    // Listen for loading state changes from map controller
    document.addEventListener('map:loading-start', (e) => this.handleLoadingStart(e))
    document.addEventListener('map:loading-stop', (e) => this.handleLoadingStop(e))
  }

  handleLoadingStart(event) {
    const { type, key } = event.detail
    const selector = type === 'poi'
      ? `[data-layer-type="poi"][data-category="${key}"]`
      : `[data-layer-type="transit"][data-route-type="${key}"]`
    const toggle = this.element.querySelector(selector)
    if (toggle) toggle.classList.add('loading')
  }

  handleLoadingStop(event) {
    const { type, key } = event.detail
    const selector = type === 'poi'
      ? `[data-layer-type="poi"][data-category="${key}"]`
      : `[data-layer-type="transit"][data-route-type="${key}"]`
    const toggle = this.element.querySelector(selector)
    if (toggle) toggle.classList.remove('loading')
  }

  togglePanel() {
    if (this.hasPanelTarget && this.panelTarget.classList.contains('hidden')) {
      this.openPanel()
    } else {
      this.closePanel()
    }
  }

  openPanel() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove('hidden')
      localStorage.setItem('tulip-layers-panel-open', 'true')
    }
    if (this.hasFabTarget) {
      this.fabTarget.classList.add('hidden')
    }
  }

  closePanel() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add('hidden')
      localStorage.setItem('tulip-layers-panel-open', 'false')
    }
    if (this.hasFabTarget) {
      this.fabTarget.classList.remove('hidden')
    }
  }

  toggleGroup(event) {
    const header = event.currentTarget
    const group = header.closest('[data-map-layers-target="group"]')
    if (!group) return

    const isCollapsed = group.classList.contains('collapsed')
    if (isCollapsed) {
      this.expandGroup(group)
    } else {
      this.collapseGroup(group)
    }

    // Save state
    const groupId = group.dataset.groupId
    localStorage.setItem(`tulip-layers-group-${groupId}`, !isCollapsed)
  }

  collapseGroup(group) {
    group.classList.add('collapsed')
    const content = group.querySelector('.layers-group-content')
    if (content) content.classList.add('hidden')
    const chevron = group.querySelector('.layers-group-chevron')
    if (chevron) chevron.classList.remove('rotate-180')
  }

  expandGroup(group) {
    group.classList.remove('collapsed')
    const content = group.querySelector('.layers-group-content')
    if (content) content.classList.remove('hidden')
    const chevron = group.querySelector('.layers-group-chevron')
    if (chevron) chevron.classList.add('rotate-180')
  }

  toggleLayer(event) {
    const toggle = event.currentTarget
    const layerType = toggle.dataset.layerType
    const isActive = toggle.classList.contains('active')

    if (isActive) {
      toggle.classList.remove('active')
    } else {
      toggle.classList.add('active')
    }

    // Dispatch appropriate event based on layer type
    if (layerType === 'poi') {
      const category = toggle.dataset.category
      this.dispatchLayerEvent('poi', category, !isActive)
      this.updateStoredCategories()
    } else if (layerType === 'transit') {
      const routeType = toggle.dataset.routeType
      this.dispatchLayerEvent('transit', routeType, !isActive)
      this.updateStoredTransitTypes()
    } else if (layerType === 'bucket-list') {
      this.dispatchLayerEvent('bucket-list', null, !isActive)
      localStorage.setItem('tulip-bucket-list-active', !isActive)
    }
  }

  dispatchLayerEvent(type, key, active) {
    const event = new CustomEvent('layers:toggle', {
      bubbles: true,
      detail: { type, key, active }
    })
    this.element.dispatchEvent(event)
  }

  updateStoredCategories() {
    const activeCategories = []
    this.element.querySelectorAll('[data-layer-type="poi"].active').forEach(toggle => {
      activeCategories.push(toggle.dataset.category)
    })
    localStorage.setItem('tulip-active-categories', JSON.stringify(activeCategories))
  }

  updateStoredTransitTypes() {
    const activeTransitTypes = []
    this.element.querySelectorAll('[data-layer-type="transit"].active').forEach(toggle => {
      activeTransitTypes.push(toggle.dataset.routeType)
    })
    localStorage.setItem('tulip-active-transit-types', JSON.stringify(activeTransitTypes))
  }

  disconnect() {
    document.removeEventListener('map:loading-start', this.handleLoadingStart)
    document.removeEventListener('map:loading-stop', this.handleLoadingStop)
  }
}
