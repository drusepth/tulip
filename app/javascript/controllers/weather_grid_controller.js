import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid"]
  static values = {
    dailyData: Array
  }

  static conditionColors = {
    'Sunny': 'bg-[#E8B4A0]',      // coral - warm muted gold
    'Clear': 'bg-[#E8B4A0]',      // alias for Sunny (legacy data)
    'Cloudy': 'bg-slate-300',
    'Foggy': 'bg-[#C9B8A8]',      // taupe - warm earthy mist
    'Rainy': 'bg-[#9BB8C9]',      // muted dusty blue
    'Snowy': 'bg-cyan-200',
    'Stormy': 'bg-[#9E92B0]'      // lavender-dark
  }

  static conditionIcons = {
    'Sunny': '☀️',
    'Clear': '☀️',               // alias for Sunny (legacy data)
    'Cloudy': '☁️',
    'Foggy': '🌫️',
    'Rainy': '🌧️',
    'Snowy': '❄️',
    'Stormy': '⛈️'
  }

  static conditionHexColors = {
    'Sunny': { bg: '#E8B4A0', text: '#5D4E4E' },    // coral, brown text
    'Clear': { bg: '#E8B4A0', text: '#5D4E4E' },    // alias for Sunny (legacy data)
    'Cloudy': { bg: '#cbd5e1', text: '#5D4E4E' },   // slate-300, brown text
    'Foggy': { bg: '#C9B8A8', text: '#5D4E4E' },    // taupe, brown text
    'Rainy': { bg: '#9BB8C9', text: '#5D4E4E' },    // muted dusty blue, brown text
    'Snowy': { bg: '#a5f3fc', text: '#5D4E4E' },    // cyan-200, brown text
    'Stormy': { bg: '#9E92B0', text: '#ffffff' }    // lavender-dark, white text
  }

  static conditionTextColors = {
    'Sunny': 'text-gray-800',
    'Clear': 'text-gray-800',    // alias for Sunny (legacy data)
    'Cloudy': 'text-gray-800',
    'Foggy': 'text-gray-800',
    'Rainy': 'text-gray-800',
    'Snowy': 'text-gray-800',
    'Stormy': 'text-white'
  }

  connect() {
    this.renderGrid()
  }

  renderGrid() {
    const data = this.dailyDataValue
    const gridElement = this.gridTarget

    if (data.length === 0) return

    let currentMonth = null

    data.forEach((day) => {
      const date = new Date(day.date)
      const month = date.toLocaleDateString('en-US', { month: 'short' })

      // Add month label when month changes
      if (month !== currentMonth) {
        const monthLabel = document.createElement('span')
        monthLabel.textContent = month
        monthLabel.className = 'w-8 h-8 text-xs text-taupe flex items-center justify-center'
        gridElement.appendChild(monthLabel)
        currentMonth = month
      }

      const square = document.createElement('div')
      const colorClass = this.constructor.conditionColors[day.condition] || 'bg-gray-300'
      const textColorClass = this.constructor.conditionTextColors[day.condition] || 'text-gray-800'

      const dayOfMonth = date.getDate()
      const formattedDate = date.toLocaleDateString('en-US', {
        weekday: 'short',
        month: 'short',
        day: 'numeric'
      })
      const icon = this.constructor.conditionIcons[day.condition] || '🌤️'
      // Normalize "Clear" to "Sunny" for display
      const displayCondition = day.condition === 'Clear' ? 'Sunny' : day.condition
      const tooltipContent = `
        <div class="font-semibold text-base">${formattedDate}</div>
        <div class="flex items-center gap-2 mt-1">
          <span class="text-lg">${icon}</span>
          <span>${displayCondition}</span>
        </div>
        <div class="flex gap-4 mt-2 text-sm">
          <div class="flex items-center gap-1">
            <span class="text-rose-300">▲</span>
            <span>${day.high}°F</span>
          </div>
          <div class="flex items-center gap-1">
            <span class="text-sky-300">▼</span>
            <span>${day.low}°F</span>
          </div>
        </div>
      `

      const colors = this.constructor.conditionHexColors[day.condition] || { bg: '#d1d5db', text: '#1f2937' }

      square.textContent = dayOfMonth
      square.className = `w-8 h-8 rounded cursor-pointer transition-transform hover:scale-110 flex items-center justify-center text-xs font-medium ${colorClass} ${textColorClass}`
      square.dataset.controller = 'tooltip'
      square.dataset.tooltipContentValue = tooltipContent
      square.dataset.tooltipBgValue = colors.bg
      square.dataset.tooltipTextValue = colors.text
      square.dataset.action = 'mouseenter->tooltip#show mouseleave->tooltip#hide'

      gridElement.appendChild(square)
    })
  }
}
