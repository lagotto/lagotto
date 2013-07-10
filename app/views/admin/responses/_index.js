function updateResponses() {
  $.ajax({
    url: "/admin/responses",
    cache: false
  }).done(function(html){
    $("#responses").html(html);
    window.setTimeout(updateResponses, 5000);
  });
}

$(document).ready(function() {
  updateResponses();
});
$(document).load(function() {
  updateResponses();
});