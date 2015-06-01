/*global d3 */

// construct query string
var params = d3.select("#api_key"),
    colors = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#95a5a6"]);

if (!params.empty()) {
  var agent_id = params.attr('data-name');
  var query = encodeURI("/api/agent/" + agent_id);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/json; version=6")
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      var data = json.agent;
      var status = d3.entries(data.status);
      var status_title = formatPercent(data.status.refreshed / d3.sum(status, function(g) { return g.value; }));

      donutViz(status, "div#chart_status", status_title, "refreshed", colors, "works");
  });
}
