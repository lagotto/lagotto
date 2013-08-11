var doi = d3.select("dd#doi").attr('data-doi');

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
  var format_date = d3.time.format("%m/%d/%y");
  var format_number = d3.format(",d")

  d3.select("#loading-all").remove();

  var category = [{ name: "html", display_name: "HTML Views" },
                  { name: "pdf", display_name: "PDF Downloads" },
                  { name: "likes", display_name: "Likes" },
                  { name: "shares", display_name: "Shares" },
                  { name: "comments", display_name: "Comments" },
                  { name: "citations", display_name: "Citations" }];

  category.forEach(function(c) {
    d3.select("div#all").append("div")
        .attr("class", "row all-row-" + c.name)
        .attr("id", "all-" + c.name);
    data[0]["sources"].forEach(function(source) {
      var total = source.metrics[c.name];
      if (total !== null && total > 0) {
        d3.select("div#all-" + c.name).append("div")
            .attr("class", "span3 text-center dashboard dashboard-label")
            .attr("id", "all-label-" + source.name + "-" + c.name);
        if (source.events_url) {
          d3.select("div#all-label-" + source.name + "-" + c.name).append("a")
            .attr("href", function(d) { return source.events_url; })
            .append("h1")
            .attr("class", "signpost")
            .attr("id", "all-signpost-" + source.name + "-" + c.name)
            .text(function(d) { return format_number(total); });
        } else {
          d3.select("div#all-label-" + source.name + "-" + c.name).append("h1")
            .attr("class", "signpost")
            .attr("id", "all-signpost-" + source.name + "-" + c.name)
            .text(function(d) { return format_number(total); });
        }
        d3.select("div#all-label-" + source.name + "-" + c.name).append("div")
            .append("a")
            .attr("href", function(d) { return "/sources/" + source.name; })
            .text(function(d) { return source.display_name; });
      }
    });
    if (d3.selectAll("div#all").selectAll("div.all-row-" + c.name).selectAll("div.span3")[0].length > 0) {
      d3.select("div#all").insert("h2", "div.all-row-" + c.name)
        .attr("class", "border-bottom")
        .attr("id", "all-" + c.name)
        .text(c.display_name);
    } else {
      d3.selectAll("div#all").selectAll("div.all-row-" + c.name).remove();
    }
  });

  if (d3.selectAll("div#all").selectAll("div.row")[0].length == 0) {
    d3.select("div#all").append("p")
      .attr("class", "muted")
      .text("No metrics found.");
  }
});
