/*global d3 */

var query = encodeURI("/api/v5/sources");

// load the data from the Lagotto API
d3.json(query, function(error, json) {
  if (error) { return console.warn(error); }

  hBarViz(json.data, "works")
  hBarViz(json.data, "events")
});
