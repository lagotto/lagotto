/*global d3 */

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var id = params.attr('data-id');
  var query = encodeURI("/api/docs/" + id);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/vnd.lagotto+json; version=6")
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      var data = json.doc;
  });
}
