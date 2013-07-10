function updateDelayedJobs() {
  $.ajax({
    url: "/admin/delayed_jobs",
    cache: false
  }).done(function(html){
    $("#delayed_jobs").html(html);
    window.setTimeout(updateDelayedJobs, 5000);
  });
}

$("#delayed_jobs").load(function() {
  updateDelayedJobs();
});
