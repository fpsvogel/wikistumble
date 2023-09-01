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

// Close SSE connection after the next articles buffer has been filled,
// i.e. after the last turbo-stream-source on the page has been replaced
// with hidden inputs containing a new article.
import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
window.Stimulus = Application.start()

Stimulus.register("next-articles", class extends Controller {
  static targets = ["stream"]

  disconnect() {
    this.streamTargets.forEach((target) => target.streamSource.close())
  }

  streamTargetDisconnected(target) {
    target.streamSource.close()
  }
})
