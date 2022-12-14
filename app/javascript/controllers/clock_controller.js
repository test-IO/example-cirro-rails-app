import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "time" ]

  connect() {
    if (this.data.has("started-at")) {
      this.started_at = parseInt(this.data.get("started-at"));
      this.timeTarget.innerHTML = this._calculatedTime();

      setInterval(() => {
        this.timeTarget.innerHTML = this._calculatedTime();
      }, 1000)
    }
  }

  _calculatedTime() {
    let now = Math.round((new Date()).getTime() / 1000);
    let diff = now - this.started_at

    let day = 60 * 60 * 24
    let hour = 60 * 60
    let minute = 60

    if (diff >= day) {
      return ">24h"
    } else {
      if (diff >= hour) {
        let h = parseInt(diff / hour)
        let min = parseInt((diff % hour) / minute)
        let sec = (diff % hour) % minute

        return this._display(h) + ":" + this._display(min) + ":" + this._display(sec)
      } else {
        let min = parseInt(diff / minute)
        let sec = diff % minute

        return "00:" + this._display(min) + ":" + this._display(sec)
      }
    }
  }

  _display(time) {
    if (time > 9) {
      return time + ""
    } else {
      return "0" + time
    }
  }
}
