import { Controller } from "@hotwired/stimulus"
// Chart.js is loaded globally via CDN in application.html.erb

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    dailyData: Array
  }

  connect() {
    this.renderChart()
  }

  renderChart() {
    const ctx = this.canvasTarget.getContext('2d')
    const data = this.dailyDataValue

    const labels = data.map(d => {
      const date = new Date(d.date)
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    })
    const highs = data.map(d => d.high)
    const lows = data.map(d => d.low)

    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'High',
            data: highs,
            borderColor: '#c9a4a4', // rose color
            backgroundColor: 'rgba(201, 164, 164, 0.1)',
            fill: '+1',
            tension: 0.3,
            pointBackgroundColor: '#c9a4a4',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4
          },
          {
            label: 'Low',
            data: lows,
            borderColor: '#8fae8b', // sage color
            backgroundColor: 'rgba(143, 174, 139, 0.1)',
            fill: false,
            tension: 0.3,
            pointBackgroundColor: '#8fae8b',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: 'index'
        },
        plugins: {
          legend: {
            position: 'top',
            labels: {
              usePointStyle: true,
              padding: 20,
              font: {
                family: "'Source Sans 3', sans-serif"
              }
            }
          },
          tooltip: {
            backgroundColor: '#5c5347',
            titleFont: {
              family: "'Source Sans 3', sans-serif"
            },
            bodyFont: {
              family: "'Source Sans 3', sans-serif"
            },
            callbacks: {
              label: function(context) {
                return `${context.dataset.label}: ${context.parsed.y}°F`
              }
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            },
            ticks: {
              font: {
                family: "'Source Sans 3', sans-serif"
              }
            }
          },
          y: {
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              font: {
                family: "'Source Sans 3', sans-serif"
              },
              callback: function(value) {
                return value + '°F'
              }
            }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}
