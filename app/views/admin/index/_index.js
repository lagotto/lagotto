function update() {
  $.ajax({
    url: "/admin",
    cache: false
  }).done(function(html){
    $("#home").html(html);
    window.setTimeout(update, 5000);
  });
}

$(document).ready(function() {
  update();
});
$(document).load(function() {
  update();
});
