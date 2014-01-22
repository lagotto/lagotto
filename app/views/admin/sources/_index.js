var data;
var colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"];
var api_key = d3.select("h1#api_key").attr('data-api_key');

var l = 200; // left margin
var r = 120; // right margin
var w = 600; // width of drawing area
var h = 36;  // bar height
var s = 2;   // spacing between bars

d3.json("/api/v3/sources?api_key=" + api_key, function(error, json) {
  data = json;

  var formatFixed = d3.format(",.0f");

  for (var i=0; i<data.length; i++) {
    item = data[i];

    // Jobs tab
    d3.select("#queueing_count_" + item["name"]).html(number_with_delimiter(item["jobs"]["queueing"]));
    d3.select("#pending_count_" + item["name"]).html(number_with_delimiter(item["jobs"]["pending"]));
    d3.select("#working_count_" + item["name"]).html(number_with_delimiter(item["jobs"]["working"]));
    if(item["status"]["stale"]  > 0) {
      d3.select("#stale_count_" + item["name"]).html(formatFixed(item["status"]["stale"]));
    }

    // Responses tab
    d3.select("#response_count_" + item["name"]).html(number_with_delimiter(item["responses"]["count"]));
    d3.select("#average_count_" + item["name"]).html(number_with_delimiter(item["responses"]["average"]));
    if(item["error_count"] > 0) {
      d3.select("#error_count_" + item["name"]).html("<a href='/admin/alerts?source=" + item["name"] + "'>" + formatFixed(item["error_count"]) + "</a>");
    }
  };

  // remove source not needed for the following visualizations
  data = data.filter(function(d) { return d.name != "relativemetric"; });

  // Articles tab
  var chart = d3.select("div#articles").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(230,20)");

  var x = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d.article_count; })])
    .range([0, w]);
  var y = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.display_name; }))
    .rangeBands([0, (h + 2 * s) * data.length]);
  var z = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.group; }))
    .range(colors);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/admin/sources/" + d.name; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", -230) // padding-right
    .attr("dy", ".35em") // vertical-align: middle
    .text(function(d) { return d.display_name; });
  chart.selectAll("rect")
    .data(data)
    .enter().append("rect")
    .attr("fill", function(d) { return z(d.group); })
    .attr("y", function(d,i) { return y(d.display_name); })
    .attr("height", h)
    .attr("width", function(d) { return x(d.article_count); });
  chart.selectAll("text.values")
    .data(data)
    .enter().append("text")
    .attr("x", function(d) { return x(d.article_count); })
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", 5) // padding-right
    .attr("dy", ".35em") // vertical-align: middle
    .text(function(d) { return number_with_delimiter(d.article_count); });

  // Events tab
  var chart = d3.select("div#events").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(230,20)");

  var x = d3.scale.log()
    .domain([0.1, d3.max(data, function(d) { return d.event_count; })])
    .range([1, w]);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/admin/sources/" + d.name; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
    .attr("dx", -230) // padding-right
    .attr("dy", ".35em") // vertical-align: middle
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
    .attr("dy", ".35em") // vertical-align: middle
    .text(function(d) { return number_with_delimiter(d.event_count); });

  function number_with_delimiter(number) {
    if(number !== 0) {
      return formatFixed(number);
    } else {
      return null;
    }
  }
});