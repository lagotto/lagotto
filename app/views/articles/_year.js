var doi = d3.select("dd#doi").attr('data-doi');
var api_key = d3.select("dd#doi").attr('data-api_key');

d3.json(encodeURI("/api/v3/articles?api_key=" + api_key + "&ids=" + doi + "&info=history"), function(data) {

  var l = 20; // left margin
  var r = 50; // right margin
  var t = 50;  // top margin
  var w = 15; // width of each bar
  var h = 100; // height
  var pub_date = d3.time.format.iso.parse(data[0]["publication_date"]);
  var pub_year = pub_date.getFullYear();
  var this_year = (new Date).getFullYear();
  var format_number = d3.format(",d")

  d3.select("#loading-year").remove();

  var category = [{ name: "html", display_name: "HTML Views" },
                  { name: "pdf", display_name: "PDF Downloads" },
                  { name: "likes", display_name: "Likes" },
                  { name: "shares", display_name: "Shares" },
                  { name: "comments", display_name: "Comments" },
                  { name: "citations", display_name: "Citations" }];

  category.forEach(function(c) {
    data[0]["sources"].forEach(function(source, i) {
      if (source.by_year) {
        var total = source.by_year.reduce(function(i, d) { return i + d[c.name]; }, 0);
        if (total > 0) {
          d3.select("div#year").append("div")
              .attr("class", "row year-row-" + c.name)
              .attr("id", "year-" + source.name + "-" + c.name);
          d3.select("div#year-" + source.name + "-" + c.name).append("div")
              .attr("class", "span3 text-center dashboard dashboard-label")
              .attr("id", "year-label-" + source.name + "-" + c.name);
          if (source.events_url) {
            d3.select("div#year-label-" + source.name + "-" + c.name).append("a")
              .attr("href", function(d) { return source.events_url; })
              .append("h1")
              .attr("class", "signpost")
              .attr("id", "year-signpost-" + source.name + "-" + c.name)
              .text(function(d) { return format_number(total); });
          } else {
            d3.select("div#year-label-" + source.name + "-" + c.name).append("h1")
              .attr("class", "signpost")
              .attr("id", "year-signpost-" + source.name + "-" + c.name)
              .text(function(d) { return format_number(total); });
          }
          d3.select("div#year-label-" + source.name + "-" + c.name).append("div")
              .append("a")
              .attr("href", function(d) { return "/sources/" + source.name; })
              .text(function(d) { return source.display_name; });
          d3.select("div#year-" + source.name + "-" + c.name).append("div")
              .attr("class", "span9")
              .attr("id", "year-chart-" + source.name + "-" + c.name);

          var chart = d3.select("div#year-chart-" + source.name + "-" + c.name).append("svg")
            .attr("width", w * (this_year - pub_year) + l + r)
            .attr("height", h + t )
            .attr("class", "chart")
            .append("g")
            .attr("transform", "translate(20,20)");
          var x = d3.time.scale()
            .domain([pub_year, this_year])
            .range([0, (w + 1) * (this_year - pub_year)]);
          var y = d3.scale.linear()
            .domain([0, d3.max(source.by_year, function(d) { return d.total; })])
            .range([0, h]);
          chart.selectAll("rect")
            .data(source.by_year)
            .enter().append("rect")
            .attr("fill", "#789aa1")
            .attr("x", function(d) { return x(d.year); })
            .attr("y", function(d) { return h - y(d.total); })
            .attr("width", w)
            .attr("height", function(d) { return y(d.total); });
          chart.append("line")
            .attr("x1", 0)
            .attr("x2", (w + 1) * (this_year - pub_year) + w - 1)
            .attr("y1", h)
            .attr("y2", h)
            .attr("class", "line");
          chart.selectAll("rect").each(
            function(d,i){ $(this).tooltip({title: format_number(d[c.name]) + " in " + d.year, container: "body"});
          });
        }
      }
    });
    if (d3.selectAll("div#year").selectAll("div.year-row-" + c.name)[0].length > 0) {
      d3.select("div#year").insert("h2", "div.year-row-" + c.name)
        .attr("class", "border-bottom")
        .attr("id", "year-" + c.name)
        .text(c.display_name);
    }
  });

  if (d3.selectAll("div#year").selectAll("div.row")[0].length == 0) {
    d3.select("div#year").append("p")
      .attr("class", "muted")
      .text("No metrics by year found.");
  }
});
