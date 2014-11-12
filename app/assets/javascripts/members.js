$(document).ready(function() {
  $("#time_bank_committee_id").change(function() {
    var comm_id = $(this);
    var admin_id = $("#time_bank_admin_id");
    var tt = $("#time_bank_time_type");
    if (comm_id.val() === "") {
      if (tt.val() === "committee") {
        tt.val("");
      }
      admin_id.val("");

    } else {
      tt.val("committee");
      $.ajax({
        url: "/committees/"+comm_id.val()+".json"
      }).success(function(data) {
        admin_id.val(data.member_id);
      });
    }
  });
});
