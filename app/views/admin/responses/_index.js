function updateResponses() {
  $.ajax({
    url: "/admin/responses",
    cache: false
  }).done(function(html){
    $("#responses").html(html);
    window.setTimeout(updateResponses, 5000);
  });
}

$("#responses").load(function() {
  updateResponses();
});