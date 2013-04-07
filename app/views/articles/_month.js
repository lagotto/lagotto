var doi = d3.select("dd#doi").attr('data-doi');

function getYearMon(d) {
    return new Date(d.year, d.month);
}

d3.json("/api/v3/articles/info:doi/" + doi + "?info=history", function(data) {

  var l = 20; // left margin
  var r = 50; // right margin
  var t = 50;  // top margin
  var w = 5; // w of each bar
  var h = 100; // height
  var colors = ["#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1"];
  var pub_date = d3.time.format.iso.parse(data[0]["publication_date"]);
  var cur_date = new Date;
  var months = d3.time.month.range(pub_date, cur_date).length + 1;
  var yearmon = d3.time.format("%b %y");

  d3.select("#loading-month").remove();
  d3.select("div#month").append("p").text("Metrics by month. Information not available for all sources.");
  
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
        .attr("w", (w + 1) * months + l + r)
        .attr("height", h + t )
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(20,20)");
      var x = d3.time.scale()
        .domain([pub_date, cur_date])
        .range([0, (w + 1) * months]);
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
        .attr("x", function(d) { return x(getYearMon(d)) })
        .attr("y", function(d) { return h - y(d.total); })
        .attr("width", w)
        .attr("height", function(d) { return y(d.total); });
      chart.append("line")
        .attr("x1", 0)
        .attr("x2", (w + 1) * months + 10)
        .attr("y1", h)        
        .attr("y2", h)
        .attr("class", "line");
        chart.selectAll("rect").each(
          function(d,i){ $(this).tooltip({title: d.total + " in " + yearmon(new Date(d.year, d.month - 1)), container: "body"});
        });
    }
  });
  
  if (d3.selectAll("div#month").selectAll("div.row")[0].length == 0) {
    d3.select("div#month").append("p")
      .attr("class", "muted")
      .text("No metrics by month found.");
  }
});