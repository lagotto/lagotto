/*global d3 */

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources/"))
  .await(function(error, s) {
    if (error) { return console.warn(error); }
    hBarViz(s.sources, "work")
    hBarViz(s.sources, "event")
});
