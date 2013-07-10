function updateHome() {
  $.ajax({
    url: "/admin",
    cache: false
  }).done(function(html){
    $("#home").html(html);
    window.setTimeout(updateHome, 5000);
  });
}

$(document).ready(function() {
  updateHome();
});
$(document).load(function() {
  updateHome();
});
