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
    var agent = data[i];

    // summary tab
    d3.select("#queued_count_" + agent.id)
      .text(numberWithDelimiter(agent.status.queued));
    d3.select("#stale_count_" + agent.id)
      .text(numberWithDelimiter(agent.status.stale));

    // responses tab
    d3.select("#response_count_" + agent.id)
      .text(numberWithDelimiter(agent.responses.count));
    d3.select("#average_count_" + agent.id)
      .text(numberWithDelimiter(agent.responses.average));
  }
}
