$(document).ready(function() {
  $("#time_bank_start_1i").change(function() {
    $("#time_bank_finish_1i").val($(this).val());
  });
  $("#time_bank_start_2i").change(function() {
    $("#time_bank_finish_2i").val($(this).val());
  });
  $("#time_bank_start_3i").change(function() {
    $("#time_bank_finish_3i").val($(this).val());
  });
});
