var data = <%= raw @data_article %>;

var color = d3.scale.ordinal()
    .range(["#304345","#789aa1","#c7c0b5"]);

var w = 300,
    h = 200,                          
    radius = Math.min(w, h) / 2;
    
var chart = d3.select("div#chart_month").append("svg")          
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
    .value(function(d) { return d.month; });
 
var arcs = chart.selectAll("g.slice") 
    .data(pie)        
    .enter()                
    .append("svg:g") 
    .attr("class", "slice"); 
 
arcs.append("svg:path")
    .attr("fill", function(d, i) { return color(i); } )
    .attr("d", arc);
    
arcs.append("svg:title")
    .text(function(d) { return d.data.month.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + " articles " + d.data.name });
    
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