// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import "bootstrap"
import { Tooltip, Popover } from "bootstrap"
import '../stylesheets/application'


import Chart from 'chart.js/auto';

Rails.start()
Turbolinks.start()
ActiveStorage.start()

document.addEventListener("turbolinks:load", () => {
    // Both of these are from the Bootstrap 5 docs
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new Tooltip(tooltipTriggerEl)
    })

    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    var popoverList = popoverTriggerList.map(function(popoverTriggerEl) {
        return new Popover(popoverTriggerEl)
    })
})

document.addEventListener('turbolinks:load', () => {
  var ctx = document.getElementById('standingsChart').getContext('2d');
  var standingsChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: JSON.parse(ctx.canvas.dataset.labels),
      datasets: JSON.parse(ctx.canvas.dataset.data)
    },
    options: {
      indexAxis: 'y',
      scales: {
        y: {
          stacked: true
        },
        x: {
          stacked: true
        }
      }
    }
  });
})
