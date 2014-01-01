var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');
var key = d3.select("h1#api_key").attr('data-key');

d3.json("/api/v3/api_requests?api_key=" + api_key + (key != "" ? "&key=" + key : ""), function(error, json) {
  data = json;

  console.log(data);

  if (data.length == 0) {
    d3.select("div.col-md-12").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("No API requests found");
    d3.select("div#charts").remove();
    d3.select("div#lists").remove();
    return;
  }

  var today = new Date();

  // Various formatters.
  var formatNumber = d3.format(",d"),
      formatFixed = d3.format(",.1f"),
      formatDate = d3.time.format("%B %d, %Y"),
      formatTime = d3.time.format("%I:%M %p");

  // A nest operator, for grouping the request list.
  var nestByDate = d3.nest()
      .key(function(d) { return d3.time.day(d.date); });

  // A little coercion, since the JSON is untyped.
  data.forEach(function(d, i) {
    d.index = i;
    d.date = parseDate(d.date);
  });

  // Create the crossfilter for the relevant dimensions and groups.
  var request = crossfilter(data),
      all = request.groupAll(),
      date = request.dimension(function(d) { return d3.time.day(d.date); }),
      dates = date.group(),
      hour = request.dimension(function(d) { return d.date.getHours() + d.date.getMinutes() / 60; }),
      hours = hour.group(Math.floor),
      db_duration = request.dimension(function(d) { return Math.max(-60, Math.min(149, d.db_duration)); }),
      db_durations = db_duration.group(function(d) { return Math.floor(d / 10) * 10; }),
      view_duration = request.dimension(function(d) { return Math.min(1999, d.view_duration); }),
      view_durations = view_duration.group(function(d) { return Math.floor(d / 50) * 50; });

  var charts = [

    barChart()
        .dimension(hour)
        .group(hours)
        .x(d3.scale.linear()
        .domain([0, 24])
        .rangeRound([0, 10 * 30])),

    barChart()
        .dimension(db_duration)
        .group(db_durations)
        .x(d3.scale.linear()
        .domain([0, 500])
        .rangeRound([0, 10 * 30])),

    barChart()
        .dimension(view_duration)
        .group(view_durations)
        .x(d3.scale.linear()
        .domain([0, 2000])
        .rangeRound([0, 10 * 30]))

  ];

  // Given our array of charts, which we assume are in the same order as the
  // .req-chart elements in the DOM, bind the charts to the DOM and render them.
  // We also listen to the chart's brush events to update the display.
  var chart = d3.selectAll(".req-chart")
      .data(charts)
      .each(function(chart) { chart.on("brush", renderAll).on("brushend", renderAll); });

  // Render the initial lists.
  var list = d3.selectAll(".list")
      .data([requestList]);

  // Render the total.
  d3.selectAll("#total")
      .text(formatNumber(request.size()));

  renderAll();

  // Renders the specified chart or list.
  function render(method) {
    d3.select(this).call(method);
  }

  // Whenever the brush moves, re-rendering everything.
  function renderAll() {
    chart.each(render);
    list.each(render);
    d3.select("#active").text(formatNumber(all.value()));
  }

  // Like d3.time.format, but faster.
  function parseDate(d) {
    return new Date(2013,
        d.substring(0, 2) - 1,
        d.substring(2, 4),
        d.substring(4, 6),
        d.substring(6, 8));
  }

  window.filter = function(filters) {
    filters.forEach(function(d, i) { charts[i].filter(d); });
    renderAll();
  };

  window.reset = function(i) {
    charts[i].filter(null);
    renderAll();
  };

  function requestList(div) {
    var requestsByDate = nestByDate.entries(date.top(40));

    div.each(function() {
      var date = d3.select(this).selectAll(".date")
          .data(requestsByDate, function(d) { return d.key; });

      date.enter().append("div")
          .attr("class", "date")
          .append("div")
          .attr("class", "day")
          .text(function(d) { return formatDate(d.values[0].date); });

      date.exit().remove();

      var request = date.order().selectAll(".request")
          .data(function(d) { return d.values; }, function(d) { return d.index; });

      var requestEnter = request.enter().append("div")
          .attr("class", "request");

      requestEnter.append("div")
          .attr("class", "time")
          .text(function(d) { return formatTime(d.date); });

      requestEnter.append("div")
          .attr("class", "duration")
          .text(function(d) { return formatFixed(d.db_duration) + " ms"; });

      requestEnter.append("div")
          .attr("class", "duration")
          .classed("fast", function(d) { return d.view_duration < 100; })
          .classed("slow", function(d) { return d.view_duration >= 1000; })
          .text(function(d) { return formatFixed(d.view_duration) + " ms"; });

      requestEnter.append("div")
          .attr("class", "source hidden-xs")
          .append("a")
          .attr("href", function(d) { return "/admin/users?query=" + d.api_key; })
          .text(function(d) { return d.api_key; });

      requestEnter.append("div")
          .attr("class", "info hidden-xs")
          .text(function(d) { return d.info; });

      requestEnter.append("div")
          .attr("class", "source hidden-xs")
          .text(function(d) { return d.source; });

      requestEnter.append("div")
          .attr("class", "ids hidden-xs")
          .text(function(d) { return d.ids; });

      request.exit().remove();

      request.order();
    });
  }

  function barChart() {
    if (!barChart.id) barChart.id = 0;

    var margin = {top: 10, right: 20, bottom: 20, left: 10},
        x,
        y = d3.scale.linear().range([100, 0]),
        id = barChart.id++,
        axis = d3.svg.axis().orient("bottom"),
        brush = d3.svg.brush(),
        brushDirty,
        dimension,
        group,
        round;

    function chart(div) {
      var width = x.range()[1],
          height = y.range()[0];

      y.domain([0, group.top(1)[0].value]);

      div.each(function() {
        var div = d3.select(this),
            g = div.select("g");

        // Create the skeletal chart.
        if (g.empty()) {
          div.select(".req-chart h5").append("a")
              .attr("href", "javascript:reset(" + id + ")")
              .attr("class", "reset")
              .text("reset")
              .style("display", "none");

          g = div.append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
              .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          g.append("clipPath")
              .attr("id", "clip-" + id)
              .append("rect")
              .attr("width", width)
              .attr("height", height);

          g.selectAll(".bar")
              .data(["background", "foreground"])
              .enter().append("path")
              .attr("class", function(d) { return d + " bar"; })
              .datum(group.all());

          g.selectAll(".foreground.bar")
              .attr("clip-path", "url(#clip-" + id + ")");

          g.append("g")
              .attr("class", "axis")
              .attr("transform", "translate(0," + height + ")")
              .call(axis);

          // Initialize the brush component with pretty resize handles.
          var gBrush = g.append("g").attr("class", "brush").call(brush);
          gBrush.selectAll("rect").attr("height", height);
          gBrush.selectAll(".resize").append("path").attr("d", resizePath);
        }

        // Only redraw the brush if set externally.
        if (brushDirty) {
          brushDirty = false;
          g.selectAll(".brush").call(brush);
          div.select(".req-chart h5 a").style("display", brush.empty() ? "none" : null);
          if (brush.empty()) {
            g.selectAll("#clip-" + id + " rect")
                .attr("x", 0)
                .attr("width", width);
          } else {
            var extent = brush.extent();
            g.selectAll("#clip-" + id + " rect")
                .attr("x", x(extent[0]))
                .attr("width", x(extent[1]) - x(extent[0]));
          }
        }

        g.selectAll(".bar").attr("d", barPath);
      });

      function barPath(groups) {
        var path = [],
            i = -1,
            n = groups.length,
            d;
        while (++i < n) {
          d = groups[i];
          path.push("M", x(d.key), ",", height, "V", y(d.value), "h9V", height);
        }
        return path.join("");
      }

      function resizePath(d) {
        var e = +(d == "e"),
            x = e ? 1 : -1,
            y = height / 3;
        return "M" + (.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
            + "Z"
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
      }
    }

    brush.on("brushstart.req-chart", function() {
      var div = d3.select(this.parentNode.parentNode.parentNode);
      div.select(".req-chart h5 a").style("display", null);
    });

    brush.on("brush.req-chart", function() {
      var g = d3.select(this.parentNode),
          extent = brush.extent();
      if (round) g.select(".brush")
          .call(brush.extent(extent = extent.map(round)))
          .selectAll(".resize")
          .style("display", null);
      g.select("#clip-" + id + " rect")
          .attr("x", x(extent[0]))
          .attr("width", x(extent[1]) - x(extent[0]));
      dimension.filterRange(extent);
    });

    brush.on("brushend.req-chart", function() {
      if (brush.empty()) {
        var div = d3.select(this.parentNode.parentNode.parentNode);
        div.select(".req-chart h5 a").style("display", "none");
        div.select("#clip-" + id + " rect").attr("x", null).attr("width", "100%");
        dimension.filterAll();
      }
    });

    chart.margin = function(_) {
      if (!arguments.length) return margin;
      margin = _;
      return chart;
    };

    chart.x = function(_) {
      if (!arguments.length) return x;
      x = _;
      axis.scale(x);
      brush.x(x);
      return chart;
    };

    chart.y = function(_) {
      if (!arguments.length) return y;
      y = _;
      return chart;
    };

    chart.dimension = function(_) {
      if (!arguments.length) return dimension;
      dimension = _;
      return chart;
    };

    chart.filter = function(_) {
      if (_) {
        brush.extent(_);
        dimension.filterRange(_);
      } else {
        brush.clear();
        dimension.filterAll();
      }
      brushDirty = true;
      return chart;
    };

    chart.group = function(_) {
      if (!arguments.length) return group;
      group = _;
      return chart;
    };

    chart.round = function(_) {
      if (!arguments.length) return round;
      round = _;
      return chart;
    };

    return d3.rebind(chart, brush, "on");
  }
});