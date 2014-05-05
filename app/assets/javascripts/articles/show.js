// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var uid_type = params.attr('data-uid_type');
  var uid = params.attr('data-uid');
  var query = encodeURI("/api/v5/articles?api_key=" + api_key + "&ids=" + uid + "&type=" + uid_type);
}

// load the data from the ALM API
if (query) {
  d3.json(query, function(error, json) {
    if (error) return console.warn(error);

    eventViz(json);
  });
}

// add data to page
function eventViz(json) {
  data = json['data'];

  // d3.select("#update_date").html(formatTime(inputTime.parse(data["update_date"])));

  // // Summary table
  // d3.select("#response_count").html(numberWithDelimiter(data["responses"]["count"]));

  // d3.select("#average_count").html(numberWithDelimiter(data["responses"]["average"]));
  // d3.select("#maximum_count").html(numberWithDelimiter(data["responses"]["maximum"]));

  // d3.select("#article_count").html(numberWithDelimiter(data["article_count"]));
  // d3.select("#event_count").html(numberWithDelimiter(data["event_count"]));
};
