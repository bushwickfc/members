/**
 * Applies the Bootstrap 3 Datetimepicker to the specified selector.
 *  Formatted to MySQL DATETIME to ease compatibility with dates in the past.
 * @see vendor/assets/bootstrap-datetimepicker.js
 * @return VOID
 */
var dateWorkedDatetimepicker = function() {
  $('#datetimepicker-dateworked').datetimepicker({format: 'YYYY-MM-DD HH:mm:ss'});
};

// Both doc.ready and doc.on(page:load) must be called due to Turbolinks. The
//  doc.ready() is effectively unbound every time Turbolinks AJAX loads <body>
//  content. Thus doc.on(page:load) is required to call the same activity when
//  the page initially loads via Turbolinks.
$(document).ready(dateWorkedDatetimepicker);
$(document).on('page:load', dateWorkedDatetimepicker);
