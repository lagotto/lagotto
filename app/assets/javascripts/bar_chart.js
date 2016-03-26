/*global d3, startDate, endDate, startTime, endTime, formatWeek, formatHour, numberToHumanSize, formatFixed, formatDate, formatTime, numberWithDelimiter */

var width = 250,
    height = 100,
    margin = { top: 7, right: 10, bottom: 5, left: 5 },
    colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"],
    l = 250, // left margin
    r = 150, // right margin
    w = 400, // width of drawing area
    h = 24,  // bar height
    s = 2;   // spacing between bars

// bar chart
function barViz(data, div, count, format) {
  var x = d3.time.scale.utc()
      .domain([startTime, endDate])
      .rangeRound([0, width]);
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
      var timestamp = Date.parse(d.key + ':00:01Z');
      var hour = formatHour(new Date(timestamp));
      return (hour >= 11 && hour <= 22) ? "bar viewed-alt" : "bar viewed"; })
    .attr("x", function(d) {
      return x(new Date(Date.parse(d.key + ':00:00Z'))); })
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
      } else if (count === "requests_average") {
        var title = formatFixed(d.values[count]) + " ms";
      } else {
        var title = formatFixed(d.values[count]);
      }

      var timestamp = Date.parse(d.key + ':00:00Z');
      var dateString = " at " + formatTime(new Date(timestamp));

      $(this).tooltip({ title: title + dateString, container: "body"});
    }
  );

  d3.select(div + "-loading").remove();

  // return chart object
  return chart;
}

// horizontal bar chart
function hBarViz(data, name) {
  // make sure we have data for the chart
  if (typeof data === "undefined") {
    d3.select("#" + name + "-loading").remove();
    return;
  }

  // remove source not appropriate for the following visualizations
  data = data.filter(function(d) { return ["relations","events"].indexOf(d.group_id) != -1; });

  // Works tab
  var chart = d3.select("div#" + name + "-body").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(" + l + "," + h + ")");

  if (name === "work") {
    var x = d3.scale.linear()
      .domain([0, d3.max(data, function(d) { return d[name + "_count"]; })])
      .range([0, w]);
  } else {
    var x = d3.scale.log()
      .domain([0.1, d3.max(data, function(d) { return d[name + "_count"]; })])
      .range([1, w]);
  }
  var y = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.title; }))
    .rangeBands([0, (h + 2 * s) * data.length]);
  var z = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.group_id; }))
    .range(colors);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/sources/" + d.id; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.title) + y.rangeBand() / 2; })
    .attr("dx", 0 - l) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return d.title; });
  chart.selectAll("rect")
    .data(data)
    .enter().append("rect")
    .attr("fill", function(d) { return z(d.group_id); })
    .attr("y", function(d) { return y(d.title); })
    .attr("height", h)
    .attr("width", function(d) { return x(d[name + "_count"]); });
  chart.selectAll("text.values")
    .data(data)
    .enter().append("text")
    .attr("x", function(d) { return x(d[name + "_count"]); })
    .attr("y", function(d) { return y(d.title) + y.rangeBand() / 2; })
    .attr("dx", 5) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return numberWithDelimiter(d[name + "_count"]); });

  d3.select("#" + name + "-loading").remove();
}
