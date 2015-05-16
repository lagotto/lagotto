/*global d3 */

var radius = 80;

// donut chart
function donutViz(data, div, title, subtitle, colors, items) {
  var chart = d3.select(div).append("svg")
    .data([data])
    .attr("width", radius * 2 + 50)
    .attr("height", radius * 2)
    .attr("class", "chart donut")
    .append("svg:g")
    .attr("transform", "translate(" + (radius + 20) + "," + radius + ")");

  var arc = d3.svg.arc()
    .outerRadius(radius - 5)
    .innerRadius(radius - 30);

  var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.value; });

  var arcs = chart.selectAll("g.slice")
    .data(pie)
    .enter()
    .append("svg:g")
    .attr("class", "slice");

  arcs.append("svg:path")
    .attr("fill", function(d, i) { return colors(i); } )
    .attr("d", arc);
  arcs.each(
    function(d){ $(this).tooltip({title: formatFixed(d.data.value) + " " + items + " " + d.data.key.replace("_", " "), container: "body"});
  });

  chart.append("text")
    .attr("dy", 0)
    .attr("text-anchor", "middle")
    .attr("class", "title")
    .text(title);

  chart.append("text")
    .attr("dy", 21)
    .attr("text-anchor", "middle")
    .attr("class", "subtitle")
    .text(subtitle);

  d3.select(div + "-loading").remove();

  // return chart object
  return chart;
}
