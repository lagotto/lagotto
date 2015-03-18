/*global d3 */

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var source_id = params.attr('data-name');
  var query = encodeURI("/api/v5/sources/" + source_id);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;
    var status = d3.entries(data.status);
    var by_day = d3.entries(data.by_day);
    var by_month = d3.entries(data.by_month);

    var status_title = formatPercent(data.status.refreshed / d3.sum(status, function(g) { return g.value; }));
    var by_day_title = formatPercent(data.by_day.with_events / d3.sum(by_day, function(g) { return g.value; }));
    var by_month_title = formatPercent(data.by_month.with_events / d3.sum(by_month, function(g) { return g.value; }));

    donutViz(status, "div#chart_status", status_title, "refreshed");
    donutViz(by_day, "div#chart_day", by_day_title, "with events");
    donutViz(by_month, "div#chart_month", by_month_title, "with events");
  });
}
