var l = 20; // left margin
var r = 50; // right margin
var t = 50;  // top margin
var w = 26; // width of each bar
var h = 100; // height

var doi = d3.select("dd#doi").attr('data-doi');

d3.json("/api/v3/articles/info:doi/" + doi + "?info=by_year", function(error, data) {
  
  d3.select("#loading-year").remove();
  
  var pub_date = d3.time.format.iso.parse(data[0]["publication_date"]);
  var pub_year = pub_date.getFullYear();
  var this_year = (new Date).getFullYear();

  data[0]["sources"].forEach(function(source, i) {
    if (source.by_year) {
      d3.select("div#year").append("div")
        .attr("class", "row")
        .attr("id", "year-" + source.name);
      d3.select("div#year-" + source.name).append("div")
        .attr("class", "span3 text-center dashboard dashboard-label")
        .attr("id", "year-label-" + source.name);    
      if (source.events_url) {
        d3.select("div#year-label-" + source.name).append("a")
          .attr("href", function(d) { return source.events_url; })
          .append("h1")
          .attr("class", "signpost")
          .attr("id", "year-signpost-" + source.name)
          .text(function(d) { return source.metrics.total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); });
      } else {
        d3.select("div#year-label-" + source.name).append("h1")
          .attr("class", "signpost")
          .attr("id", "year-signpost-" + source.name)
          .text(function(d) { return source.metrics.total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); });
      }
      d3.select("div#year-label-" + source.name).append("div")
        .append("a")
        .attr("href", function(d) { return "/sources/" + source.name; })
        .text(function(d) { return source.display_name; });
      d3.select("div#year-" + source.name).append("div")
        .attr("class", "span5")
        .attr("id", "year-chart-" + source.name);
          
      var chart = d3.select("div#year-chart-" + source.name).append("svg")
        .attr("width", w * (this_year - pub_year) + l + r)
        .attr("height", h + t )
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(20,20)");
      var x = d3.time.scale()
        .domain([pub_year, this_year])
        .range([0, w * (this_year - pub_year)]);
      var y = d3.scale.linear()
        .domain([0, d3.max(source.by_year, function(d) { return d.total; })])
        .range([0, h]);
      chart.selectAll("rect")
        .data(source.by_year)
        .enter().append("rect")
        .attr("fill", "#789aa1")
        .attr("x", function(d) { return x(d.year); })
        .attr("y", function(d) { return h - y(d.total); })
        .attr("width", 25)
        .attr("height", function(d) { return y(d.total); });
      chart.append("line")
        .attr("x1", 0)
        .attr("x2", w * (this_year - pub_year) + 25)
        .attr("y1", h)        
        .attr("y2", h)
        .attr("class", "line");
    }
  });
});