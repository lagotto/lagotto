var d3,
    width = 250,
    height = 100,
    radius = 80,
    margin = { top: 7, right: 10, bottom: 5, left: 5 },
    color = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#f1c40f"]),
    formatFixed = d3.format(",.0f"),
    formatPercent = d3.format(",.0%"),
    formatDate = d3.time.format("%d %b %y"),
    formatTime = d3.time.format("%H:%M"),
    formatWeek = d3.time.format.utc("%U"),
    formatDaytime = d3.time.format.utc("%p"),
    endDate = new Date(),
    startDate = d3.time.day.offset(endDate, -29),
    endTime = endDate.setHours(23, 00, 00),
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

// bar chart
function barViz(data, div, count, format) {
  if (format == "days") {
    var x = d3.time.scale.utc()
      .domain([startDate, endDate])
      .rangeRound([0, width]);
  } else {
    var x = d3.time.scale.utc()
      .domain([startTime, endDate])
      .rangeRound([0, width]);
  }

  var y = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d.values[count]; })])
    .rangeRound([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .tickSize(0)
    .ticks(0);

  var chart = d3.select(div).append("svg")
    .data([data])
    .attr("width", margin.left + width + margin.right)
    .attr("height", margin.top + height + margin.bottom)
    .attr("class", "chart barchart")
    .append("svg:g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var bar = chart.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", function(d) {
      if (format == "days") {
        var timestamp = Date.parse(d.key + 'T12:00:00Z');
        var weekNumber = formatWeek(new Date(timestamp));
        return (weekNumber % 2 == 0) ? "bar viewed" : "bar viewed-alt";
      } else {
        var timestamp = Date.parse(d.key + ':00:01Z');
        var daytime = formatDaytime(new Date(timestamp));
        return (daytime == "AM") ? "bar viewed" : "bar viewed-alt";
      }})
    .attr("x", function(d) {
      if (format == "days") {
        return x(new Date(Date.parse(d.key + 'T12:00:00Z')));
      } else {
        return x(new Date(Date.parse(d.key + ':00:00Z')));
      }})
    .attr("width", width/30 - 1)
    .attr("y", function(d) { return y(d.values[count]); })
    .attr("height", function(d) { return height - y(d.values[count]); });

  chart.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  chart.selectAll("rect").each(
    function(d) {
      if (count == "db_size") {
        var title = numberToHumanSize(d.values[count]);
      } else if (count == "requests_average") {
        var title = formatFixed(d.values[count]) + " ms";
      } else {
        var title = formatFixed(d.values[count]);
      }

      if (format == "days") {
        var timestamp = Date.parse(d.key + 'T12:00:00Z');
        var date_string = " on " + formatDate(new Date(timestamp));
      } else {
        var timestamp = Date.parse(d.key + ':00:00Z');
        var date_string = " at " + formatTime(new Date(timestamp));
      }

      $(this).tooltip({ title: title + date_string, container: "body"});
    }
  );

  d3.select(div + "-loading").remove();

  // return chart object
  return chart;
}

// donut chart
function donutViz(data, div, title, subtitle) {
  var chart = d3.select(div).append("svg")
    .data([data])
    .attr("width", radius * 2 + 50)
    .attr("height", radius * 2)
    .attr("class", "chart donut")
    .append("svg:g")
    .attr("transform", "translate(" + (radius + 20) + "," + radius + ")");

  var arc = d3.svg.arc()
    .outerRadius(radius - 5)
    .innerRadius(radius - 30);

  var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.value; });

  var arcs = chart.selectAll("g.slice")
    .data(pie)
    .enter()
    .append("svg:g")
    .attr("class", "slice");

  arcs.append("svg:path")
    .attr("fill", function(d, i) { return color(i); } )
    .attr("d", arc);
  arcs.each(
    function(d){ $(this).tooltip({title: formatFixed(d.data.value) + " sources " + d.data.key.replace("_", " "), container: "body"});
  });

  chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle")
    .attr("class", "title")
    .text(title);

  chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle")
    .attr("class", "subtitle")
    .text(subtitle);

  d3.select(div + "-loading").remove();

  // return chart object
  return chart;
}

// Format file size into human-readable format
function numberToHumanSize(bytes) {
  var thresh = 1000;
  if(bytes < thresh) return bytes + ' B';
  var units = ['KB','MB','GB','TB','PB'];
  var u = -1;
  do {
      bytes /= thresh;
      ++u;
  } while(bytes >= thresh);
  return bytes.toFixed(1)+' '+units[u];
};
