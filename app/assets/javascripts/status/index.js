/*global d3 */

var endDate = new Date(),
    startDate = d3.time.day.offset(endDate, -29),
    endTime = endDate.setHours(23),
    startTime = d3.time.hour.offset(endTime, -23);

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var query = encodeURI("/api/v5/status?api_key=" + api_key);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;

    // aggregate status by day
    var day_data = data.filter(function(status) {
      return Date.parse(status.update_date) >= startDate;
    });
    var by_day = d3.nest()
      .key(function(d) { return d.update_date.substr(0,10); })
      .rollup(function(leaves) {
        return { "works_count": d3.max(leaves, function(d) { return d.works_new_count;}),
                 "events_count": d3.max(leaves, function(d) { return d.events_count;}),
                 "alerts_count": d3.max(leaves, function(d) { return d.alerts_count;}),
                 "db_size": d3.max(leaves, function(d) { return d.db_size;}),
                };})
      .entries(day_data);

    // aggregate status by hour
    var hour_data = data.filter(function(status) {
      return Date.parse(status.update_date) >= startTime;
    });
    var by_hour = d3.nest()
      .key(function(d) { return d.update_date.substr(0,13); })
      .rollup(function(leaves) {
        return { "responses_count": d3.max(leaves, function(d) { return d.responses_count;}),
                 "requests_count": d3.max(leaves, function(d) { return d.requests_count;}),
                 "requests_average": d3.mean(leaves, function(d) { return d.requests_average;}),
                };})
      .entries(hour_data);

    var sources = d3.entries(data[0].sources);
    var sources_title = d3.sum(sources, function(g) { return g.value; });

    barViz(by_day, "#chart_works", "works_count", "days");
    barViz(by_day, "#chart_events", "events_count", "days");
    barViz(by_day, "#chart_alerts", "alerts_count", "days");
    barViz(by_day, "#chart_db_size", "db_size", "days");

    barViz(by_hour, "#chart_responses", "responses_count", "hours");
    barViz(by_hour, "#chart_requests", "requests_count", "hours");
    barViz(by_hour, "#chart_average", "requests_average", "hours");

    donutViz(sources, "#chart_sources", sources_title, "active");
  });
}
