var d3,
    colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"],
    l = 250, // left margin
    r = 150, // right margin
    w = 400, // width of drawing area
    h = 24,  // bar height
    s = 2;   // spacing between bars

// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var query = encodeURI("/api/v5/sources?api_key=" + api_key);
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;

    worksViz(data);
    eventsViz(data);
  });
}

// works bar chart
function worksViz(data) {

  // remove source not needed for the following visualizations
  data = data.filter(function(d) { return d.name !== "relativemetric"; });

  // Works tab
  var chart = d3.select("div#works-body").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(" + l + "," + h + ")");

  var x = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d.work_count; })])
    .range([0, w]);
  var y = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.display_name; }))
    .rangeBands([0, (h + 2 * s) * data.length]);
  var z = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.group; }))
    .range(colors);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/sources/" + d.name; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", 0 - l) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return d.display_name; });
  chart.selectAll("rect")
    .data(data)
    .enter().append("rect")
    .attr("fill", function(d) { return z(d.group); })
    .attr("y", function(d) { return y(d.display_name); })
    .attr("height", h)
    .attr("width", function(d) { return x(d.work_count); });
  chart.selectAll("text.values")
    .data(data)
    .enter().append("text")
    .attr("x", function(d) { return x(d.work_count); })
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", 5) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return numberWithDelimiter(d.work_count); });

  d3.select("#works-loading").remove();
}

// events bar chart
function eventsViz(data) {

  // remove source not needed for the following visualizations
  data = data.filter(function(d) { return d.name !== "relativemetric"; });

  // Events tab
  var chart = d3.select("div#events-body").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(" + l + "," + h + ")");

  var x = d3.scale.log()
    .domain([0.1, d3.max(data, function(d) { return d.event_count; })])
    .range([1, w]);
  var y = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.display_name; }))
    .rangeBands([0, (h + 2 * s) * data.length]);
  var z = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.group; }))
    .range(colors);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/sources/" + d.name; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", 0 - l) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return d.display_name; });
  chart.selectAll("rect")
    .data(data)
    .enter().append("rect")
    .attr("fill", function(d) { return z(d.group); })
    .attr("y", function(d) { return y(d.display_name); })
    .attr("height", h)
    .attr("width", function(d) { return x(d.event_count); });
  chart.selectAll("text.values")
    .data(data)
    .enter().append("text")
    .attr("x", function(d) { return x(d.event_count); })
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", 5) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return numberWithDelimiter(d.event_count); });

  d3.select("#events-loading").remove();
}

// d3 helper functions
var formatFixed = d3.format(",.0f");

function numberWithDelimiter(number) {
  if(number !== 0) {
    return formatFixed(number);
  } else {
    return null;
  }
}
