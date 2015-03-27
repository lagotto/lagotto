/*global d3 */

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var source_id = params.attr('data-name');
  var query = encodeURI("/api/v6/sources/" + source_id);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.source;
    var status = d3.entries(data.status);
    var byDay = d3.entries(data.byDay);
    var byMonth = d3.entries(data.byMonth);

    var status_title = formatPercent(data.status.refreshed / d3.sum(status, function(g) { return g.value; }));
    var byDayTitle = formatPercent(data.byDay.with_events / d3.sum(byDay, function(g) { return g.value; }));
    var byMonthTitle = formatPercent(data.byMonth.with_events / d3.sum(byMonth, function(g) { return g.value; }));

    donutViz(status, "div#chart_status", status_title, "refreshed");
    donutViz(byDay, "div#chart_day", byDayTitle, "with events");
    donutViz(byMonth, "div#chart_month", byMonthTitle, "with events");
  });
}
