import { Controller } from "@hotwired/stimulus"

// Focuses the element when it connects, so the field gets focus on every
// Turbo Drive visit and not only on full page loads (where the HTML
// autofocus attribute already applies).
export default class extends Controller {
  connect() {
    this.element.focus()
  }
}
