import { Controller } from "@hotwired/stimulus"

// Handles @-mention autocomplete for places in comment textareas.
// Attach to a wrapper element containing the textarea and a dropdown container.
//
// Values:
//   search-url: the URL to fetch place suggestions (e.g. /stays/:id/place_search)
//
// Targets:
//   textarea: the comment body textarea
//   dropdown: the autocomplete dropdown container
export default class extends Controller {
  static targets = ["textarea", "dropdown"]
  static values  = { searchUrl: String }

  connect() {
    this.mentionActive = false
    this.mentionStart  = null  // caret position where '@' was typed
    this.selectedIndex = 0
    this.results       = []
    this.debounceTimer = null
  }

  disconnect() {
    this.hideDropdown()
    if (this.debounceTimer) clearTimeout(this.debounceTimer)
  }

  // Called on every keyup in the textarea
  onInput() {
    const textarea = this.textareaTarget
    const caret    = textarea.selectionStart
    const text     = textarea.value

    // Find the last un-closed '@' before the caret
    const beforeCaret = text.substring(0, caret)
    const atIndex     = beforeCaret.lastIndexOf("@")

    if (atIndex === -1) {
      this.deactivate()
      return
    }

    // Make sure the '@' is at the start or preceded by whitespace
    if (atIndex > 0 && !/\s/.test(text[atIndex - 1])) {
      this.deactivate()
      return
    }

    const query = beforeCaret.substring(atIndex + 1)

    // If the query contains a newline after '@', deactivate
    if (query.includes("\n")) {
      this.deactivate()
      return
    }

    this.mentionActive = true
    this.mentionStart  = atIndex

    if (query.length === 0) {
      this.hideDropdown()
      return
    }

    this.debouncedSearch(query)
  }

  // Called on keydown to handle navigation and selection
  onKeydown(event) {
    if (!this.mentionActive || !this.hasDropdownTarget || this.dropdownTarget.classList.contains("hidden")) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.results.length - 1)
        this.highlightItem()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightItem()
        break
      case "Enter":
      case "Tab":
        if (this.results.length > 0) {
          event.preventDefault()
          this.selectResult(this.results[this.selectedIndex])
        }
        break
      case "Escape":
        event.preventDefault()
        this.deactivate()
        break
    }
  }

  debouncedSearch(query) {
    if (this.debounceTimer) clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.search(query), 200)
  }

  async search(query) {
    if (!this.searchUrlValue) return

    try {
      const url = `${this.searchUrlValue}?q=${encodeURIComponent(query)}`
      const response = await fetch(url, {
        headers: { "Accept": "application/json" }
      })
      if (!response.ok) return

      this.results = await response.json()
      this.selectedIndex = 0
      this.renderDropdown()
    } catch (e) {
      // silently fail on network errors
    }
  }

  renderDropdown() {
    if (!this.hasDropdownTarget) return
    const dropdown = this.dropdownTarget

    if (this.results.length === 0) {
      this.hideDropdown()
      return
    }

    const categoryEmojis = {
      coffee: "\u2615",
      food: "\uD83C\uDF5D",
      grocery: "\uD83D\uDED2",
      gym: "\uD83D\uDCAA",
      coworking: "\uD83D\uDCBB",
      library: "\uD83D\uDCDA",
      parks: "\uD83C\uDF33",
      bus_stops: "\uD83D\uDE8C",
      stations: "\uD83D\uDE89"
    }

    dropdown.innerHTML = this.results.map((place, i) => {
      const emoji = categoryEmojis[place.category] || "\uD83D\uDCCD"
      const selected = i === this.selectedIndex ? "mention-item-selected" : ""
      return `<button type="button"
        class="mention-item ${selected}"
        data-action="click->place-mention#pickItem"
        data-place-id="${place.id}"
        data-place-name="${this.escapeHtml(place.name)}"
        data-index="${i}">
        <span class="mention-item-emoji">${emoji}</span>
        <span class="mention-item-details">
          <span class="mention-item-name">${this.escapeHtml(place.name)}</span>
          ${place.address ? `<span class="mention-item-address">${this.escapeHtml(place.address)}</span>` : ""}
        </span>
      </button>`
    }).join("")

    dropdown.classList.remove("hidden")
  }

  highlightItem() {
    if (!this.hasDropdownTarget) return
    const items = this.dropdownTarget.querySelectorAll(".mention-item")
    items.forEach((item, i) => {
      item.classList.toggle("mention-item-selected", i === this.selectedIndex)
    })
  }

  pickItem(event) {
    event.preventDefault()
    const btn = event.currentTarget
    const place = {
      id: btn.dataset.placeId,
      name: btn.dataset.placeName
    }
    this.selectResult(place)
  }

  selectResult(place) {
    const textarea = this.textareaTarget
    const text     = textarea.value
    const before   = text.substring(0, this.mentionStart)
    const caret    = textarea.selectionStart
    const after    = text.substring(caret)

    const mention = `@[${place.name}](place:${place.id}) `
    textarea.value = before + mention + after

    // Set caret after the mention
    const newCaret = before.length + mention.length
    textarea.setSelectionRange(newCaret, newCaret)
    textarea.focus()

    this.deactivate()
  }

  deactivate() {
    this.mentionActive = false
    this.mentionStart  = null
    this.results       = []
    this.selectedIndex = 0
    this.hideDropdown()
  }

  hideDropdown() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden")
      this.dropdownTarget.innerHTML = ""
    }
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
