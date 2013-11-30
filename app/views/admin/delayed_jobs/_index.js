var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');

d3.json("/api/v3/delayed_jobs?api_key=" + api_key, function(error, json) {
  data = json;

  var formatFixed = d3.format(",.0f");

  for (var i=0; i<data.length; i++) {
    item = data[i];
    d3.select("#queueing_count_" + item["id"]).html(number_with_delimiter(item["queueing_count"]));
    d3.select("#pending_count_" + item["id"]).html(number_with_delimiter(item["pending_count"]));
    d3.select("#working_count_" + item["id"]).html(number_with_delimiter(item["working_count"]));
    if(item["stale_count"] !== null) {
      d3.select("#stale_count_" + item["id"]).html(number_with_delimiter(item["stale_count"]));
    }
  };

  function number_with_delimiter(number) {
    if(number !== 0) {
      return formatFixed(number);
    } else {
      return null;
    }
  }
});