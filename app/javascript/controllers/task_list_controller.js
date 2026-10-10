import { Controller } from "@hotwired/stimulus"

// Drag and drop reordering of the open tasks in a list.
// Cards are live-reordered in the DOM while dragging; the new order is
// persisted via PATCH to the list's tasks reorder endpoint on drop.
export default class extends Controller {
  static targets = ["card"]
  static values = { reorderUrl: String }

  connect() {
    this.draggedCard = null
    this.orderBefore = null
  }

  dragstart(event) {
    this.draggedCard = event.target.closest(".task-card")
    if (!this.draggedCard) return

    this.orderBefore = this.currentOrder()
    this.draggedCard.classList.add("is-dragging")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedCard.dataset.taskId)
  }

  dragover(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const card = event.target.closest("[data-task-list-target='card']")
    if (!card || card === this.draggedCard) return

    const rect = card.getBoundingClientRect()
    const insertAfter = event.clientY > rect.top + rect.height / 2

    if (insertAfter) {
      card.after(this.draggedCard)
    } else {
      card.before(this.draggedCard)
    }
  }

  drop(event) {
    event.preventDefault()
  }

  dragend() {
    if (!this.draggedCard) return

    this.draggedCard.classList.remove("is-dragging")
    this.draggedCard = null

    const order = this.currentOrder()
    if (order.join(",") !== this.orderBefore?.join(",")) {
      this.persistOrder(order)
    }
    this.orderBefore = null
  }

  currentOrder() {
    return this.cardTargets.map((card) => card.dataset.taskId)
  }

  async persistOrder(taskIds) {
    try {
      const response = await fetch(this.reorderUrlValue, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ task_ids: taskIds })
      })

      if (!response.ok) window.location.reload()
    } catch (_error) {
      window.location.reload()
    }
  }
}
