/*global d3 */

var query = encodeURI("/api/sources");

// load the data from the Lagotto API
d3.json(query)
  .header("Accept", "application/vnd.lagotto+json; version=6")
  .get(function(error, json) {
    if (error) { return console.warn(error); }

    hBarViz(json.data, "works")
    hBarViz(json.data, "events")
});
