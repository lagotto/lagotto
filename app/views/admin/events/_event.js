var data = <%= raw @data %>;
var colors = ["#304345","#789aa1","#a0d5d6","#ad9a27","#a17f78"]
  
var l = 200; // left margin
var r = 120; // right margin
var w = 600; // width of drawing area
var h = 30;  // bar height
var s = 1;   // spacing between bars
  
var chart = d3.select("div#event").append("svg")
  .attr("width", w + l + r)
  .attr("height", data.length * (h + 2 * s) + 30)
  .attr("class", "chart")
  .append("g")
  .attr("transform", "translate(230,20)");
var x = d3.scale.log()
  .domain([0.1, d3.max(data, function(d) { return d.event_count; })])
  .range([1, w]);
var y = d3.scale.ordinal()
  .domain(data.map(function(d) { return d.name; }))
  .rangeBands([0, (h + 2 * s) * data.length]);
var z = d3.scale.ordinal()
  .domain(data.map(function(d) { return d.group; }))
  .range(colors);
chart.selectAll("text.labels")
  .data(data)
  .enter().append("a").attr("xlink:href", function(d) { return d.url; }).append("text")
  .attr("x", 0)
  .attr("y", function(d) { return y(d.name) + y.rangeBand() / 2; })
  .attr("dx", -230) // padding-right
  .attr("dy", ".35em") // vertical-align: middle
  .text(function(d) { return d.name; })
chart.selectAll("rect")
  .data(data)
  .enter().append("rect")
  .attr("fill", function(d) { return z(d.group); })
  .attr("y", function(d) { return y(d.name); })
  .attr("height", h)
  .transition().duration(500).delay(200)
  .attr("width", function(d) { return x(d.event_count); });
chart.selectAll("text.values")
  .data(data)
  .enter().append("text")
  .attr("x", function(d) { return x(d.event_count); })
  .attr("y", function(d) { return y(d.name) + y.rangeBand() / 2; })
  .attr("dx", 5) // padding-right
  .attr("dy", ".35em") // vertical-align: middle
  .text(function(d) { return d.event_count.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","); })
