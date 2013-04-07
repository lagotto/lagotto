var doi = d3.select("dd#doi").attr('data-doi');

function getDate(d) { return new Date(d.year, d.month - 1, d.day); }

function formatNumber(d) { return d.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); }

d3.json("/api/v3/articles/info:doi/" + doi + "?info=history", function(data) {

  var l = 20; // left margin
  var r = 50; // right margin
  var t = 50;  // top margin
  var w = 15; // width of each bar
  var h = 100; // height
  var colors = ["#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1","#304345","#789aa1"];
  var pub_date = d3.time.format.iso.parse(data[0]["publication_date"]);
  var days = 29;
  var end_date = new Date(pub_date.getTime() + days * 24 * 60 * 60 * 1000);
  var short_date = d3.time.format("%m/%d/%y");
  
  d3.select("#loading-day").remove();
  d3.select("div#day").append("p").text("Metrics in the first 30 days after publication. Information not available for all sources.");

  data[0]["sources"].forEach(function(source) {
    if (source.by_day) {
      var total = source.by_day.reduce(function(i, d) { return i + d.total; }, 0);
      d3.select("div#day").append("div")
          .attr("class", "row")
          .attr("id", "day-" + source.name);
      d3.select("div#day-" + source.name).append("div")
          .attr("class", "span3 text-center dashboard dashboard-label")
          .attr("id", "day-label-" + source.name);
      if (source.events_url) {
        d3.select("div#day-label-" + source.name).append("a")
          .attr("href", function(d) { return source.events_url; })
          .append("h1")
          .attr("class", "signpost")
          .attr("id", "day-signpost-" + source.name)
          .text(function(d) { return formatNumber(total); });
      } else {
        d3.select("div#day-label-" + source.name).append("h1")
          .attr("class", "signpost")
          .attr("id", "day-signpost-" + source.name)
          .text(function(d) { return formatNumber(total); });
      }
      d3.select("div#day-label-" + source.name).append("div")
          .append("a")
          .attr("href", function(d) { return "/sources/" + source.name; })
          .text(function(d) { return source.display_name; });
      d3.select("div#day-" + source.name).append("div")
          .attr("class", "span9")
          .attr("id", "day-chart-" + source.name);
          
      var chart = d3.select("div#day-chart-" + source.name).append("svg")
        .attr("width", (w + 1) * days + l + r)
        .attr("height", h + t )
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(20,20)");
      var x = d3.time.scale()
        .domain([pub_date, end_date])
        .range([0, (w + 1) * days]);
      var y = d3.scale.linear()
        .domain([0, d3.max(source.by_day, function(d) { return d.total; })])
        .range([0, h]);
      var z = d3.scale.ordinal()
        .domain(source.by_day.map(function(d) { return d.month; }))
        .range(colors);
      chart.selectAll("rect")
        .data(source.by_day)
        .enter().append("rect")
        .attr("fill", function(d) { return z(d.month); })
        .attr("x", function(d) { return x(new Date(d.year, d.month - 1, d.day)) })
        .attr("y", function(d) { return h - y(d.total); })
        .attr("width", w)
        .attr("height", function(d) { return y(d.total); });
      chart.append("line")
        .attr("x1", 0)
        .attr("x2", (w + 1) * days + 8)
        .attr("y1", h)        
        .attr("y2", h)
        .attr("class", "line");
      chart.selectAll("rect").each(
        function(d,i){ $(this).tooltip({title: d.total + " on " + short_date(new Date(d.year, d.month - 1, d.day)), container: "body"});
      });
    }
  });
  
  if (d3.selectAll("div#day").selectAll("div.row")[0].length == 0) {
    d3.select("div#day").append("p")
      .attr("class", "muted")
      .text("No metrics by day found.");
  }
});