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

    // Sortable round table functionality
    document.querySelectorAll('.sortable-header').forEach(header => {
        header.addEventListener('click', function() {
            const table = this.closest('table')
            const tbody = table.querySelector('tbody')
            const rows = Array.from(tbody.querySelectorAll('tr'))
            const columnIndex = this.dataset.columnIndex
            const isTotal = this.dataset.sortType === 'total'
            const currentSort = this.dataset.sortState || 'none'

            let newSort
            if (isTotal) {
                newSort = 'total'
            } else {
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

                if (isTotal) {
                    // For total column, use original rank
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
                    // For matchup columns, sort by max_points
                    const aCell = a.querySelector(`[data-column-index="${columnIndex}"]`)
                    const bCell = b.querySelector(`[data-column-index="${columnIndex}"]`)
                    aVal = aCell ? parseFloat(aCell.dataset.sortValue || '0') : 0
                    bVal = bCell ? parseFloat(bCell.dataset.sortValue || '0') : 0

                    return newSort === 'max_points_desc' ? bVal - aVal : aVal - bVal
                }
            })

            // Re-append rows in sorted order
            rows.forEach(row => tbody.appendChild(row))
        })
    })
})
