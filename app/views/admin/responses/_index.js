var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');

d3.json("/api/v3/sources?api_key=" + api_key, function(error, json) {
  data = json;

  var formatFixed = d3.format(",.0f");

  for (var i=0; i<data.length; i++) {
    item = data[i];
    d3.select("#response_count_" + item["name"]).html(number_with_delimiter(item["response_count"]));
    d3.select("#response_duration_" + item["name"]).html(number_with_delimiter(item["response_duration"]));
    d3.select("#error_count_" + item["name"]).html(number_with_delimiter(item["error_count"]));
  };

  function number_with_delimiter(number) {
    if(number !== 0) {
      return formatFixed(number);
    } else {
      return null;
    }
  }
});