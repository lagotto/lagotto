/*global d3 */

var colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"],
    l = 250, // left margin
    r = 150, // right margin
    w = 400, // width of drawing area
    h = 24,  // bar height
    s = 2,   // spacing between bars
    formatFixed = d3.format(",.0f");

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
