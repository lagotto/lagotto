/*global d3 */

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/agents/"))
  .await(function(error, a) {
    if (error) { return console.warn(error); }
    agentsViz(a.agents);
});

// add data to page
function agentsViz(data) {

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
