var doi = d3.select("dd#doi").attr('data-doi');

function getformat_date(d) { return new Date(d.year, d.month); }

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
  var format_date = d3.time.format("%b %y");
  var format_number = d3.format(",d")

  d3.select("#loading-month").remove();
  
  var category = [{ name: "html", display_name: "HTML Views" },
                  { name: "pdf", display_name: "PDF Downloads" },                 
                  { name: "comments", display_name: "Social Shares" },
                  { name: "shares", display_name: "Academic Bookmarks" },
                  { name: "citations", display_name: "Citations" }];
                  
  category.forEach(function(c) {
    data[0]["sources"].forEach(function(source) {
      if (source.by_month) {
        var total = source.by_month.reduce(function(i, d) { return i + d[c.name]; }, 0);
        if (total > 0) {
          d3.select("div#month").append("div")
              .attr("class", "row month-row-" + c.name)
              .attr("id", "month-" + source.name + "-" + c.name);
          d3.select("div#month-" + source.name + "-" + c.name).append("div")
              .attr("class", "span3 text-center dashboard dashboard-label")
              .attr("id", "month-label-" + source.name + "-" + c.name);
          if (source.events_url) {
            d3.select("div#month-label-" + source.name + "-" + c.name).append("a")
              .attr("href", function(d) { return source.events_url; })
              .append("h1")
              .attr("class", "signpost")
              .attr("id", "month-signpost-" + source.name + "-" + c.name)
              .text(function(d) { return format_number(total); });
          } else {
            d3.select("div#month-label-" + source.name + "-" + c.name).append("h1")
              .attr("class", "signpost")
              .attr("id", "month-signpost-" + source.name + "-" + c.name)
              .text(function(d) { return format_number(total); });
          }
          d3.select("div#month-label-" + source.name + "-" + c.name).append("div")
              .append("a")
              .attr("href", function(d) { return "/sources/" + source.name; })
              .text(function(d) { return source.display_name; });
          d3.select("div#month-" + source.name + "-" + c.name).append("div")
              .attr("class", "span9")
              .attr("id", "month-chart-" + source.name + "-" + c.name);
          
          var chart = d3.select("div#month-chart-" + source.name + "-" + c.name).append("svg")
            .attr("w", (w + 1) * months + l + r)
            .attr("height", h + t )
            .attr("class", "chart")
            .append("g")
            .attr("transform", "translate(20,20)");
          var x = d3.time.scale()
            .domain([pub_date, cur_date])
            .range([0, (w + 1) * months]);
          var y = d3.scale.linear()
            .domain([0, d3.max(source.by_month, function(d) { return d[c.name]; })])
            .range([0, h]);
          var z = d3.scale.ordinal()
            .domain(source.by_month.map(function(d) { return d.year; }))
            .range(colors);
          chart.selectAll("rect")
            .data(source.by_month)
            .enter().append("rect")
            .attr("fill", function(d) { return z(d.year); })
            .attr("x", function(d) { return x(getformat_date(d)) })
            .attr("y", function(d) { return h - y(d[c.name]); })
            .attr("width", w)
            .attr("height", function(d) { return y(d[c.name]); });
          chart.append("line")
            .attr("x1", 0)
            .attr("x2", (w + 1) * months + 10)
            .attr("y1", h)        
            .attr("y2", h)
            .attr("class", "line");
            chart.selectAll("rect").each(
              function(d,i){ $(this).tooltip({title: format_number(d[c.name]) + " in " + format_date(new Date(d.year, d.month - 1)), container: "body"});
            });
        }
      }
    });
    if (d3.selectAll("div#month").selectAll("div.month-row-" + c.name)[0].length > 0) {
      d3.select("div#month").insert("h2", "div.month-row-" + c.name)
        .attr("class", "border-bottom")
        .attr("id", "month-" + c.name)
        .text(c.display_name);
    }
  });
  
  if (d3.selectAll("div#month").selectAll("div.row")[0].length > 0) {
    d3.select("div#month").insert("p", ":first-child")
      .text("Metrics by month. Information not available for all sources.");
  } else {
    d3.select("div#month").append("p")
      .attr("class", "muted")
      .text("No metrics by month found.");
  }
});