import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "value", "submit" ]

  display(evt) {
    const fileName = evt.target.value.split('\\').pop();

    if (this.valueTarget.nodeName == 'INPUT') {
      this.valueTarget.placeholder = fileName;
    } else {
      this.valueTarget.innerHTML = fileName;
    }

    if (fileName == "") {
      this.submitTarget.classList.add("hidden")
    } else {
      this.submitTarget.classList.remove("hidden")
    }
  }
}
