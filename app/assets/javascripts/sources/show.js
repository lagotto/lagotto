/*global d3 */

// construct query string
var params = d3.select("#api_key"),
    colors = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#95a5a6"]);

if (!params.empty()) {
  var source_id = params.attr('data-name');
  var query = encodeURI("/api/sources/" + source_id);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/json; version=6")
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      var data = json.source;
      var status = d3.entries(data.status);
      var byDay = d3.entries(data.by_day);
      var byMonth = d3.entries(data.by_month);

      var status_title = formatPercent(data.status.refreshed / d3.sum(status, function(g) { return g.value; }));
      var byDayTitle = formatPercent(data.by_day.with_events / d3.sum(byDay, function(g) { return g.value; }));
      var byMonthTitle = formatPercent(data.by_month.with_events / d3.sum(byMonth, function(g) { return g.value; }));

      donutViz(status, "div#chart_status", status_title, "refreshed", colors);
      donutViz(byDay, "div#chart_day", byDayTitle, "with events", colors);
      donutViz(byMonth, "div#chart_month", byMonthTitle, "with events", colors);
  });
}
