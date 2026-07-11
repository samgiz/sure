import { Controller } from "@hotwired/stimulus"

// Form helpers for the UserView new/edit form.
//   - toggleAll: check or uncheck every account_ids checkbox at once.
//   - toggleGroup: same but scoped to a single accountable_type group.
export default class extends Controller {
  static targets = ["accountCheckbox", "ownerCheckbox", "allBtn"]

  toggleAll(event) {
    event.preventDefault()
    const anyUnchecked = this.accountCheckboxTargets.some((cb) => !cb.checked)
    this.accountCheckboxTargets.forEach((cb) => (cb.checked = anyUnchecked))
  }

  toggleGroup(event) {
    event.preventDefault()
    const group = event.currentTarget.dataset.groupName
    const checkboxes = this.accountCheckboxTargets.filter(
      (cb) => cb.dataset.group === group
    )
    const anyUnchecked = checkboxes.some((cb) => !cb.checked)
    checkboxes.forEach((cb) => (cb.checked = anyUnchecked))
  }
}
