import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static targets = ["message", "toast"]

  connect() {
    let delay = 0;

    this.toastTargets.forEach((toast) => {
      const messageElement = toast.querySelector("span");
      const message = messageElement ? messageElement.innerText : "";
      const wordCount = message.trim().split(/\s+/).length;
      const timeout = wordCount * 1000;

      delay += timeout;

      setTimeout(() => {
        toast.style.transition = "opacity 0.5s ease";
        toast.style.opacity = "0";
        setTimeout(() => toast.remove(), 500);
      }, timeout);
    });

    setTimeout(() => {
      this.element.remove();
    }, delay + 1000);
  }
}
