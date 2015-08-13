/**
 * Applies the Bootstrap 3 Datetimepicker to the specified selector. The input
 *  is set to readonly to prevent erroneous user input, and valid dates from 
 *  the datetimepicker calendar are allowed via the 'ignoreReadonly' parameter.
 *  Input is formatted to MySQL DATETIME to ease compatibility with dates in
 *  the past.
 * @return VOID
 */
var dateWorkedDatetimepicker = function() {
  $('#datetimepicker-dateworked>input.form-control').prop("readonly", true);
  $('#datetimepicker-dateworked').datetimepicker({format: 'YYYY-MM-DD', ignoreReadonly: true});
};

// Both doc.ready and doc.on(page:load) must be called due to Turbolinks. The
//  doc.ready() is effectively unbound every time Turbolinks AJAX loads <body>
//  content. Thus doc.on(page:load) is required to call the same activity when
//  the page initially loads via Turbolinks.
$(document).ready(dateWorkedDatetimepicker);
$(document).on('page:load', dateWorkedDatetimepicker);