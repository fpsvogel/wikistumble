import "$styles/index.css"
import "$styles/syntax-highlighting.css"
import * as Turbo from "@hotwired/turbo"

/**
 * Adds support for declarative shadow DOM. Requires your HTML <head> to include:
 * `<meta name="turbo-cache-control" content="no-cache" />`
 */
import * as TurboShadow from "turbo-shadow"

/**
 * Uncomment the line below to add transition animations when Turbo navigates.
 * Use data-turbo-transition="false" on your <main> element for pages where
 * you don't want any transition animation.
 */
// import "./turbo_transitions.js"

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}"

console.info("Bridgetown is loaded!")
