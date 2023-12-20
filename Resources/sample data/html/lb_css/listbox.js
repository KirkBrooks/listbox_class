/* listbox.js */

// add on hover listener to .lb-cell elements
var cells = document.querySelectorAll('.lb-cell');
for (var i = 0; i < cells.length; i++) {
    cells[i].addEventListener('mouseover', function(e) {
        var target = e.target;
        if (target.classList.contains('lb-cell')) {
            target.classList.toggle('cell-hover');
        }
    });
    cells[i].addEventListener('mouseout', function(e) {
        var target = e.target;
        if (target.classList.contains('lb-cell')) {
            target.classList.toggle('cell-hover');
        }
    });
}

/* add on click listener to .lb-grid-row elements */
var rows = document.querySelectorAll('.lb-grid-row');
for (var i = 0; i < rows.length; i++) {
    rows[i].addEventListener('click', function(e) {
        var target = e.target.closest('.lb-grid-row');
        if (target) {
            target.classList.toggle('row-selected');
        }
    });
}

