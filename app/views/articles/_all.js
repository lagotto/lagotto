d3.json("/api/v3/groups", function(groups) {
  
  d3.select("#loading").remove();
  
  groups.forEach(function(group) {
  
    d3.select("div#all").append("h2")
      .attr("class", "border-bottom")
      .attr("id", group.name)
      .text(group.name);
      
     d3.select("h2#" + group.name).append("div")
      .attr("class", "row")
      .attr("id", group.name);
      
    group.sources.forEach(function(source) {
      d3.select("div#" + group.name).append("div")
        .attr("class", "span3 text-center dashboard")
        .append("div")
        .text(source.display_name);
    });
  });
});