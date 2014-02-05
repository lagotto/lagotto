var data;
var name = d3.select("h1").attr('data-name');
var api_key = d3.select("h1").attr('data-api_key');
var color = d3.scale.ordinal()
    .range(["#1abc9c","#ecf0f1","#95a5a6"]);
var w = 300,
    h = 200,
    radius = Math.min(w, h) / 2;

d3.json("/api/v5/sources/" + name + "?api_key=" + api_key, function(error, json) {
  data = json["data"];

  var formatFixed = d3.format(",.0f");

  // Summary table
  d3.select("#pending_count").html(number_with_delimiter(data["jobs"]["pending"]));
  d3.select("#working_count").html(number_with_delimiter(data["jobs"]["working"]));

  d3.select("#response_count").html(number_with_delimiter(data["responses"]["count"]));
  if(data["error_count"] > 0) {
    d3.select("#error_count").html("<a href='/admin/alerts?source=" + name + "'>" + formatFixed(data["error_count"]) + "</a>");
  }

  d3.select("#average_count").html(number_with_delimiter(data["responses"]["average"]));
  d3.select("#maximum_count").html(number_with_delimiter(data["responses"]["maximum"]));

  d3.select("#article_count").html(number_with_delimiter(data["article_count"]));
  d3.select("#event_count").html(number_with_delimiter(data["event_count"]));

  // Status donut chart
  data = d3.entries(json["status"]);

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

  // Events today donut chart
  data = d3.entries(json["by_day"]);

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

  // Events this month donut chart
  data = d3.entries(json["by_month"]);

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

  function number_with_delimiter(number) {
    if(number !== 0) {
      return formatFixed(number);
    } else {
      return null;
    }
  }
});