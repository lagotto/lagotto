var colors = ["#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1"];

var l = 20; // left margin
var r = 50; // right margin
var t = 50;  // top margin
var width = 3; // width of each bar
var h = 100; // height

var doi = d3.select("dd#doi").attr('data-doi');

function getDate(d) {
    return new Date(d.year, d.month);
}

d3.json("/api/v3/articles/info:doi/" + doi + "?info=by_month", function(data) {
  
  d3.select("#loading-month").remove();
  
  var pub_date = d3.time.format.iso.parse(data[0]["publication_date"]);
  var cur_date = new Date;
  var months = d3.time.month.range(pub_date, cur_date).length + 1;

  data[0]["sources"].forEach(function(source) {
    if (source.by_month) {
      d3.select("div#month").append("div")
          .attr("class", "row")
          .attr("id", "month-" + source.name);
      d3.select("div#month-" + source.name).append("div")
          .attr("class", "span3 text-center dashboard dashboard-label")
          .attr("id", "month-label-" + source.name);
      if (source.events_url) {
        d3.select("div#month-label-" + source.name).append("a")
          .attr("href", function(d) { return source.events_url; })
          .append("h1")
          .attr("class", "signpost")
          .attr("id", "month-signpost-" + source.name)
          .text(function(d) { return source.metrics.total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); });
      } else {
        d3.select("div#month-label-" + source.name).append("h1")
          .attr("class", "signpost")
          .attr("id", "month-signpost-" + source.name)
          .text(function(d) { return source.metrics.total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); });
      }
      d3.select("div#month-label-" + source.name).append("div")
          .append("a")
          .attr("href", function(d) { return "/sources/" + source.name; })
          .text(function(d) { return source.display_name; });
      d3.select("div#month-" + source.name).append("div")
          .attr("class", "span9")
          .attr("id", "month-chart-" + source.name);
          
      var chart = d3.select("div#month-chart-" + source.name).append("svg")
        .attr("width", (width + 3) * months + l + r)
        .attr("height", h + t )
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(20,20)");
      var x = d3.time.scale()
        .domain([pub_date, cur_date])
        .range([0, (width + 3) * months]);
      var y = d3.scale.linear()
        .domain([0, d3.max(source.by_month, function(d) { return d.total; })])
        .range([0, h]);
      var z = d3.scale.ordinal()
        .domain(source.by_month.map(function(d) { return d.year; }))
        .range(colors);
      chart.selectAll("rect")
        .data(source.by_month)
        .enter().append("rect")
        .attr("fill", function(d) { return z(d.year); })
        .attr("x", function(d) { return x(getDate(d)) })
        .attr("y", function(d) { return h - y(d.total); })
        .attr("width", width)
        .attr("height", function(d) { return y(d.total); });
      chart.append("line")
        .attr("x1", 0)
        .attr("x2", (width + 3) * months + 4)
        .attr("y1", h)        
        .attr("y2", h)
        .attr("class", "line");
    }
  });
});