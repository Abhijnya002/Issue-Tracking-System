import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    readonly: { type: Boolean, default: false },
    fragmentTemplate: String
  }

  static targets = ["list"]

  connect () {
    if (this.readonlyValue) return

    this.sortables = this.listTargets.map((list) =>
      Sortable.create(list, {
        group: "board",
        animation: 160,
        handle: "[data-drag-handle]",
        draggable: "[data-issue-id]",
        ghostClass: "sortable-ghost",
        chosenClass: "sortable-chosen",
        onEnd: (evt) => this.persist(evt)
      })
    )
  }

  disconnect () {
    if (this.sortables) {
      this.sortables.forEach((s) => s.destroy())
      this.sortables = null
    }
  }

  async persist (evt) {
    const columns = {}
    this.listTargets.forEach((list) => {
      const status = list.dataset.status
      columns[status] = [...list.querySelectorAll("[data-issue-id]")].map((el) =>
        parseInt(el.dataset.issueId, 10)
      )
    })

    const token = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")

    const response = await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ columns })
    })

    if (!response.ok) {
      const text = await response.text()
      console.error("Reorder failed", response.status, text)
      window.alert("Could not save column change. Refresh and try again.")
      return
    }

    await this.reconcileDraggedMarkup(evt)
    this.syncColumnCounts()
  }

  async reconcileDraggedMarkup (evt) {
    if (!evt || !this.hasFragmentTemplateValue) return

    const fromStatus = evt.from?.dataset?.status
    const toStatus = evt.to?.dataset?.status
    if (!fromStatus || !toStatus || fromStatus === toStatus) return

    let placement = null
    if (fromStatus === "backlog" && toStatus !== "backlog") placement = "board"
    else if (fromStatus !== "backlog" && toStatus === "backlog") placement = "backlog"
    if (!placement) return

    const item = evt.item
    const issueId = item?.dataset?.issueId
    if (!issueId) return

    const url =
      this.fragmentTemplateValue.replace("__ISSUE_ID__", issueId) +
      `?placement=${encodeURIComponent(placement)}`

    try {
      const res = await fetch(url, {
        headers: { Accept: "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!res.ok) return
      const html = await res.text()
      const wrapper = document.createElement("div")
      wrapper.innerHTML = html.trim()
      const newEl = wrapper.firstElementChild
      if (!newEl || !item.parentNode) return
      item.parentNode.replaceChild(newEl, item)
      if (window.Alpine) window.Alpine.initTree(newEl)
    } catch (e) {
      console.error("Could not refresh card markup", e)
    }
  }

  syncColumnCounts () {
    this.listTargets.forEach((list) => {
      const n = list.querySelectorAll("[data-issue-id]").length
      const section = list.closest("section")
      if (!section) return
      const badge = section.querySelector("[data-kanban-count]")
      if (badge) badge.textContent = String(n)
    })
  }
}
