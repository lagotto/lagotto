function update() {
  $.ajax({
    url: "/admin/responses",
    cache: false
  }).done(function(html){
    $("#responses").html(html);
    window.setTimeout(update, 5000);
  });
}

$(document).ready(function() {
  update();
});
$(document).load(function() {
  update();
});