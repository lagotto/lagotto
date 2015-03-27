/*global d3, barViz, donutViz */

var endDate = new Date(),
    startDate = d3.time.day.offset(endDate, -29),
    endTime = endDate.setHours(23),
    startTime = d3.time.hour.offset(endTime, -23);

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var query = encodeURI("/api/v6/status");
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Authorization", "Token token=" + api_key)
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      var data = json.status;

      // aggregate status by day
      var day_data = data.filter(function(status) {
        return Date.parse(status.updateDate) >= startDate;
      });
      var by_day = d3.nest()
        .key(function(d) { return d.updateDate.substr(0,10); })
        .rollup(function(leaves) {
          return { "works_count": d3.max(leaves, function(d) { return d.worksNewCount;}),
                   "events_count": d3.max(leaves, function(d) { return d.eventsCount;}),
                   "alerts_count": d3.max(leaves, function(d) { return d.alertsCount;}),
                   "db_size": d3.max(leaves, function(d) { return d.dbSize;}),
                  };})
        .entries(day_data);

      // aggregate status by hour
      var hour_data = data.filter(function(status) {
        return Date.parse(status.updateDate) >= startTime;
      });
      var by_hour = d3.nest()
        .key(function(d) { return d.updateDate.substr(0,13); })
        .rollup(function(leaves) {
          return { "responses_count": d3.max(leaves, function(d) { return d.responsesCount;}),
                   "requests_count": d3.max(leaves, function(d) { return d.requestsCount;}),
                   "requests_average": d3.mean(leaves, function(d) { return d.requestsAverage;}),
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
