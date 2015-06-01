/*global d3 */

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources/"))
  .await(function(error, s) {
    if (error) { return console.warn(error); }
    sourcesViz(s.sources);
    hBarViz(s.sources, "work")
    hBarViz(s.sources, "event")
});

// add data to page
function sourcesViz(data) {

  for (var i=0; i<data.length; i++) {
    var source = data[i];

    // summary tab
    d3.select("#queued_count_" + source.id)
      .text(numberWithDelimiter(source.status.queued));
    d3.select("#stale_count_" + source.id)
      .text(numberWithDelimiter(source.status.stale));

    // responses tab
    d3.select("#response_count_" + source.id)
      .text(numberWithDelimiter(source.responses.count));
    d3.select("#average_count_" + source.id)
      .text(numberWithDelimiter(source.responses.average));
  }
}
