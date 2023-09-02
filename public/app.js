// Switch between light and dark mode.
document.getElementById("theme-input").addEventListener("click", (event) => {
  const htmlElement = document.getElementsByTagName('html')[0]

  if (event.target.checked) {
    htmlElement.classList.add('dark');
  } else {
    htmlElement.classList.remove('dark')
  };

  // Make a POST request which saves the theme preference to the session.
  document.getElementById('submit-theme').click();
});


// Long-lived connections of several seconds are made for SSE (server-sent events)
// that stream new articles into the hidden buffer of next articles.
// The connections don't close automatically, so they need to be closed manually
// via the Stimulus controller below.

import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
window.Stimulus = Application.start()

Stimulus.register("next-articles", class extends Controller {
  static targets = ["stream"]

  // When the page is refreshed.
  disconnect() {
    this.streamTargets.forEach((target) => target.streamSource.close())
  }

  // When a <turbo-stream-source> is replaced with a next article.
  streamTargetDisconnected(target) {
    target.streamSource.close()
  }
})
