import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: String,
    end: String,
    today: String
  }

  connect() {
    // Timeline is rendered server-side via ERB
    // This controller can be used for future enhancements like:
    // - Drag and drop to reschedule stays
    // - Zoom in/out functionality
    // - Tooltip positioning
  }
}
