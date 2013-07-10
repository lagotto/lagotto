function updateHome() {
  $.ajax({
    url: "/admin",
    cache: false
  }).done(function(html){
    $("#home").html(html);
    window.setTimeout(updateHome, 5000);
  });
}

$("#home").load(function() {
  updateHome();
});
