function update() {
  $.ajax({
    url: "/admin/delayed_jobs",
    cache: false
  }).done(function(html){
    $("#delayed_jobs").html(html);
    window.setTimeout(update, 5000);
  });
}

$(document).ready(function() {
  update();
});
$(document).load(function() {
  update();
});
