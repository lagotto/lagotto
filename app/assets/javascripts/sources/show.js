var w = 300,
    h = 200,
    radius = Math.min(w, h) / 2,
    color = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#95a5a6"]),
    formatFixed = d3.format(",.0f");

// construct query string
var params = d3.select("h1");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var source_name = params.attr('data-name');
  var query = encodeURI("/api/v5/sources/" + source_name + "?api_key=" + api_key);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); };
    var data = json.data;

    statusDonutViz(data);
    dayDonutViz(data);
    monthDonutViz(data);
  });
}

// Status donut chart
function statusDonutViz(data) {
  var status = d3.entries(data.status);

  var chart = d3.select("div#chart_status").append("svg")
    .data([status])
    .attr("width", w)
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g")
    .attr("transform", "translate(150,100)");

  var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - 40);

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
    function(d){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key, container: "body"});
  });

  chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle")
    .attr("class", "title")
    .text("Status");

  chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle")
    .attr("class", "subtitle")
    .text("of articles");

}

// Events today donut chart
function dayDonutViz(data) {
  var by_day = d3.entries(data.by_day);

  var chart = d3.select("div#chart_day").append("svg")
    .data([by_day])
    .attr("width", w)
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g")
    .attr("transform", "translate(150,100)");

  var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - 40);

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
    function(d){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key.replace("_", " "), container: "body"});
  });

  chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle")
    .attr("class", "title")
    .text("Events");

  chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle")
    .attr("class", "subtitle")
    .text("last 24 hours");

  // return chart object
  return chart;
}

// Events this month donut chart
function monthDonutViz(data) {
  var by_month = d3.entries(data.by_month);

  var chart = d3.select("div#chart_month").append("svg")
    .data([by_month])
    .attr("width", w)
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g")
    .attr("transform", "translate(150,100)");

  var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(radius - 40);

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
  function(d){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key.replace("_", " "), container: "body"});
  });

  chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle")
    .attr("class", "title")
    .text("Events");

  chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle")
    .attr("class", "subtitle")
    .text("last 31 days");

  // return chart object
  return chart;
}
