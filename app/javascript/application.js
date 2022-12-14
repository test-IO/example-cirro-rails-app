// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Rails functionality
import Rails from "@rails/ujs"
import { Turbo } from "@hotwired/turbo-rails"

// Make accessible for Electron and Mobile adapters
window.Rails = Rails
window.Turbo = Turbo

require("@rails/activestorage").start()
import "@rails/actiontext"

// ActionCable Channels
import "./channels"

// Stimulus controllers
import "./controllers"

// Start Rails UJS
Rails.start()
