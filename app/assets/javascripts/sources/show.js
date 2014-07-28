var w = 300,
    h = 200,
    radius = Math.min(w, h) / 2;

// construct query string
var params = d3.select("h1");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var name = params.attr('data-name');
  var query = encodeURI("/api/v5/sources/" + name + "?api_key=" + api_key);
}

// load the data from the ALM API
if (query) {
  d3.json(query, function(error, json) {
    if (error) return console.warn(error);

    sourceViz(json);
    statusDonutViz(json);
    dayDonutViz(json);
    monthDonutViz(json);
  });
}

// add data to page
// function sourceViz(json) {
//   data = json['data'];

//   d3.select("#update_date").html(formatTime(inputTime.parse(data["update_date"])));

//   // Summary table
//   d3.select("#response_count").html(numberWithDelimiter(data["responses"]["count"]));

//   d3.select("#average_count").html(numberWithDelimiter(data["responses"]["average"]));
//   d3.select("#maximum_count").html(numberWithDelimiter(data["responses"]["maximum"]));

//   d3.select("#article_count").html(numberWithDelimiter(data["article_count"]));
//   d3.select("#event_count").html(numberWithDelimiter(data["event_count"]));
// };

// Status donut chart
function statusDonutViz(json) {
  data = d3.entries(json["data"]["status"]);

  var chart = d3.select("div#chart_status").append("svg")
    .data([data])
    .attr("width", w)
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g")
    .attr("transform", "translate(150,100)")

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
    function(d,i){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key, container: "body"});
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

};

// Events today donut chart
function dayDonutViz(json) {
  data = d3.entries(json["data"]["by_day"]);

  var chart = d3.select("div#chart_day").append("svg")
    .data([data])
    .attr("width", w)
    .attr("height", h)
    .attr("class", "chart")
    .append("svg:g")
    .attr("transform", "translate(150,100)")

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
    function(d,i){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key.replace("_", " "), container: "body"});
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
};

// Events this month donut chart
function monthDonutViz(json) {
  data = d3.entries(json["data"]["by_month"]);

  var chart = d3.select("div#chart_month").append("svg")
    .data([data])
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
  function(d,i){ $(this).tooltip({title: formatFixed(d.data.value) + " articles " + d.data.key.replace("_", " "), container: "body"});
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
};

// d3 helper functions
var color = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#95a5a6"]),
    formatFixed = d3.format(",.0f"),
    inputTime = d3.time.format.iso,
    formatTime = d3.time.format.utc("%d %b %H:%M UTC");

// add delimiters for large numbers
function numberWithDelimiter(number) {
  if(number !== 0) {
    return formatFixed(number);
  } else {
    return null;
  }
};
