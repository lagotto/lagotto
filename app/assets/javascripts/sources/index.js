/*global d3 */

// construct query string
var params = d3.select("h1#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var query = encodeURI("/api/v5/sources?api_key=" + api_key);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;

    worksViz(data);
    eventsViz(data);
  });
}
