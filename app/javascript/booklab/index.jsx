import Turbolinks from "turbolinks"
import ReactDOM from "react-dom"
import React from "react"
import "@babel/polyfill"
import "actiontext"
import "primer-booklab"
import "vendor/styleguide.js"
import "vendor/jquery.timeago.js"
import "vendor/jquery.timeago.settings.js"
import './rails-ujs-extends'

Turbolinks.start()
Turbolinks.setProgressBarDelay(150)

window.$ = jQuery
window.App = {
  locale: 'en'
}

import './editor/index.js'
import './reader/index.js'
import './follow-user/index.js'
import './comments/index.js'
import './mentionable/index.js'
import './toc-editor/index.js'

document.addEventListener("turbolinks:load", () => {
  $(".timeago").timeago();
})
