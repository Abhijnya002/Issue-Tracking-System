import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "checkbox", "clearBtn", "hint", "summary"]

  connect () {
    this.active = []
    this.syncFromCheckboxes()
    this.updateSummaryText()
    this.apply()
  }

  checkboxChange () {
    this.syncFromCheckboxes()
    this.updateSummaryText()
    this.apply()
  }

  syncFromCheckboxes () {
    if (!this.hasCheckboxTarget) {
      this.active = []
      return
    }
    this.active = this.checkboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => parseInt(cb.dataset.labelId, 10))
      .filter((id) => !Number.isNaN(id))

    if (this.hasClearBtnTarget) {
      this.clearBtnTarget.classList.toggle("hidden", this.active.length === 0)
    }
    if (this.hasHintTarget) {
      this.hintTarget.classList.toggle("hidden", this.active.length === 0)
    }
  }

  clear () {
    this.active = []
    this.checkboxTargets.forEach((cb) => {
      cb.checked = false
    })
    if (this.hasClearBtnTarget) this.clearBtnTarget.classList.add("hidden")
    if (this.hasHintTarget) this.hintTarget.classList.add("hidden")
    this.updateSummaryText()
    this.apply()
  }

  updateSummaryText () {
    if (!this.hasSummaryTarget) return
    const n = this.active.length
    if (n === 0) {
      this.summaryTarget.textContent = "Filter by tag"
    } else {
      this.summaryTarget.textContent = n === 1 ? "1 tag selected" : `${n} tags selected`
    }
  }

  apply () {
    this.cardTargets.forEach((card) => {
      const raw = card.dataset.labelIds || ""
      const ids = raw.split(",").filter(Boolean).map((x) => parseInt(x, 10))
      const show =
        this.active.length === 0 || this.active.some((fid) => ids.includes(fid))
      card.classList.toggle("hidden", !show)
    })
  }
}
