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

    // Simulation select functionality
    document.querySelectorAll('.simulation-select').forEach(select => {
        // Prevent click from triggering sortable header
        select.addEventListener('click', function(e) {
            e.stopPropagation()
        })

        select.addEventListener('change', function(e) {
            e.stopPropagation()
            const matchupId = this.dataset.matchupId
            const round = this.dataset.round
            const outcome = this.value
            const url = new URL(window.location)
            const params = new URLSearchParams(url.search)

            // Get existing sim params
            const existingSims = params.getAll('sim[]')

            // Remove any existing simulation for this matchup
            const prefix = `${matchupId}:`
            const filteredSims = existingSims.filter(s => !s.startsWith(prefix))

            // Add new simulation if an outcome was selected
            if (outcome) {
                filteredSims.push(`${matchupId}:${outcome}`)
            }

            // Update URL params
            params.delete('sim[]')
            filteredSims.forEach(sim => params.append('sim[]', sim))

            // Set the round param to stay on the current round
            params.set('round', round)

            // Reload page with new params (decode to avoid ugly URL encoding)
            url.search = decodeURIComponent(params.toString())
            Turbolinks.visit(url.toString())
        })
    })

    // Sortable round table functionality
    document.querySelectorAll('.sortable-header').forEach(header => {
        header.addEventListener('click', function() {
            const table = this.closest('table')
            const tbody = table.querySelector('tbody')
            const rows = Array.from(tbody.querySelectorAll('tr'))
            const columnIndex = this.dataset.columnIndex
            const isTotal = this.dataset.sortType === 'total'
            const isOverallTotal = this.dataset.sortType === 'overall-total'
            const currentSort = this.dataset.sortState || 'none'

            let newSort
            if (isTotal || isOverallTotal) {
                newSort = 'total'
            } else if (columnIndex) {
                // Cycle through: none -> scoring_index -> max_points_desc -> max_points_asc -> scoring_index
                if (currentSort === 'none' || currentSort === 'max_points_asc') {
                    newSort = 'scoring_index'
                } else if (currentSort === 'scoring_index') {
                    newSort = 'max_points_desc'
                } else {
                    newSort = 'max_points_asc'
                }
            }

            // Remove sort indicators from all headers
            table.querySelectorAll('.sortable-header').forEach(h => {
                h.classList.remove('sorted-asc', 'sorted-desc', 'sorted-both')
                h.dataset.sortState = 'none'
            })

            // Add sort indicator to current header
            if (newSort === 'scoring_index') {
                this.classList.add('sorted-both')
            } else if (newSort === 'max_points_asc' || newSort === 'total') {
                this.classList.add('sorted-asc')
            } else if (newSort === 'max_points_desc') {
                this.classList.add('sorted-desc')
            }
            this.dataset.sortState = newSort

            // Sort rows
            rows.sort((a, b) => {
                let aVal, bVal

                if (isOverallTotal) {
                    // For overall total column, sort by max_total with min_total as tiebreaker
                    const aCell = a.querySelector('.overall-total-cell')
                    const bCell = b.querySelector('.overall-total-cell')
                    const aMax = aCell ? parseFloat(aCell.dataset.maxTotal || '0') : 0
                    const bMax = bCell ? parseFloat(bCell.dataset.maxTotal || '0') : 0
                    const aMin = aCell ? parseFloat(aCell.dataset.minTotal || '0') : 0
                    const bMin = bCell ? parseFloat(bCell.dataset.minTotal || '0') : 0

                    const maxDiff = bMax - aMax // Descending by max
                    if (maxDiff !== 0) return maxDiff

                    return bMin - aMin // Tiebreaker: descending by min
                } else if (isTotal) {
                    // For round total column, use original rank
                    aVal = parseInt(a.cells[0].textContent)
                    bVal = parseInt(b.cells[0].textContent)
                    return aVal - bVal // Always ascending for default rank
                } else if (newSort === 'scoring_index') {
                    // Sort by scoring_index ascending
                    const aCell = a.querySelector(`[data-column-index="${columnIndex}"]`)
                    const bCell = b.querySelector(`[data-column-index="${columnIndex}"]`)
                    aVal = aCell ? parseFloat(aCell.dataset.scoringIndex || '999') : 999
                    bVal = bCell ? parseFloat(bCell.dataset.scoringIndex || '999') : 999
                    return aVal - bVal
                } else {
                    // For matchup columns, sort by max_points with min_points as tiebreaker
                    const aCell = a.querySelector(`[data-column-index="${columnIndex}"]`)
                    const bCell = b.querySelector(`[data-column-index="${columnIndex}"]`)
                    const aMax = aCell ? parseFloat(aCell.dataset.sortValue || '0') : 0
                    const bMax = bCell ? parseFloat(bCell.dataset.sortValue || '0') : 0
                    const aMin = aCell ? parseFloat(aCell.dataset.minPoints || '0') : 0
                    const bMin = bCell ? parseFloat(bCell.dataset.minPoints || '0') : 0

                    const maxDiff = newSort === 'max_points_desc' ? bMax - aMax : aMax - bMax
                    if (maxDiff !== 0) return maxDiff

                    // Tiebreaker: use min_points in same direction
                    return newSort === 'max_points_desc' ? bMin - aMin : aMin - bMin
                }
            })

            // Re-append rows in sorted order
            rows.forEach(row => tbody.appendChild(row))
        })
    })
})
