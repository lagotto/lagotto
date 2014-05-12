// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var uid_type = params.attr('data-uid_type');
  var uid = params.attr('data-uid');
  var query = encodeURI("/api/v5/articles?api_key=" + api_key + "&ids=" + uid + "&type=" + uid_type + "&info=detail");
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
  data = json['data']['sources'];

  d3.select("#loading-events").remove();

  for (var i=0; i<data.length; i++) {
    item = data[i];
    console.log(item);
  }
};
