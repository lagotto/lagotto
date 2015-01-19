var d3,
    radius = 80,
    color = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#95a5a6"]),
    formatFixed = d3.format(",.0f"),
    formatPercent = d3.format(",.0%");

// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var source_name = params.attr('data-name');
  var query = encodeURI("/api/v5/sources/" + source_name + "?api_key=" + api_key);
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
