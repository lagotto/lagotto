/**
 * ALMViz
 * See https://github.com/articlemetrics/almviz for more details
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief Article level metrics visualization controller.
 */

var options = {
  baseUrl: '',
  minItemsToShowGraph: {
    minEventsForYearly: 1,
    minEventsForMonthly: 1,
    minEventsForDaily: 1,
    minYearsForYearly: 1,
    minMonthsForMonthly: 1,
    minDaysForDaily: 1
  },
  vizDiv: "#metrics",
  showTitle: false,
  groups: [{ name: "viewed", display_name: "Viewed" },
           { name: "cited", display_name: "Cited" },
           { name: "saved", display_name: "Saved" },
           { name: "discussed", display_name: "Discussed" },
           { name: "recommended", display_name: "Recommended" }]
};

var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var uid_type = params.attr('data-uid_type');
  var uid = params.attr('data-uid');
  var query = encodeURI("/api/v5/articles?api_key=" + api_key + "&ids=" + uid + "&type=" + uid_type);
}

// load the data from the ALM API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    options.almStatsJson = json.data;
    var almviz = new AlmViz(options);
    almviz.initViz();
  });
}

function AlmViz(options) {
  // allow jQuery object to be passed in
  // in case a different version of jQuery is needed from the one globally defined
  $ = options.jQuery || $;

  // Init data
  var groups_ = options.groups;
  var data = options.almStatsJson;

  // Abort if data are missing
  if (!data || !data[0]) {
    console.log('Error: missing data');
    return null;
  }

  var additionalStats = options.additionalStatsJson;
  if (additionalStats) {
    data[0].sources.push(additionalStats);
  }

  // Init basic options
  var baseUrl_ = options.baseUrl;
  var minItems_ = options.minItemsToShowGraph;
  var showTitle = options.showTitle;
  var formatNumber_ = d3.format(",d");

  // extract publication date

  // Construct date object from date parts, using "1" for missing day and month
  var date_parts = data[0]["issued"]["date-parts"][0];
  var len = date_parts.length;
  while (date_parts.length < 3) date_parts.push(1);

  // turn numbers to strings and pad with 0
  for (var i = 0; i < date_parts.length; ++i) {
    if (date_parts[i] < 10) {
      date_parts[i] = "0" + date_parts[i];
    } else {
      date_parts[i] = "" + date_parts[i];
    }
  }
  var timestamp = Date.parse(date_parts.join('-'));
  var pub_date  = new Date(timestamp);

  var vizDiv;
  // Get the Div where the viz should go (default to one with ID "alm')
  if (options.vizDiv) {
    vizDiv = d3.select(options.vizDiv);
  } else {
    vizDiv = d3.select("#alm");
  }

  // look to make sure browser support SVG
  var hasSVG_ = document.implementation.hasFeature("http://www.w3.org/TR/SVG11/feature#BasicStructure", "1.1");

  // to track if any metrics have been found
  var metricsFound_;

  /**
   * Initialize the visualization.
   * NB: needs to be accessible from the outside for initialization
   */
  this.initViz = function() {
    vizDiv.select("#loading").remove();

    if (showTitle) {
      vizDiv.append("a")
        .attr('href', 'http://dx.doi.org/' + data[0].doi)
        .attr("class", "title")
        .text(data[0].title);
    }

    // loop through groups
    groups_.forEach(function(group) {
      addGroup_(vizDiv, group, data);
    });

    if (!metricsFound_) {
      vizDiv.append("p")
        .attr("class", "text-muted")
        .text("No metrics found.");
    }
  };

  /**
   * Build each article level statistics group.
   * @param {Object} canvas d3 element
   * @param {Array} group Information about the group.
   * @param {Object} data Statistics.
   * @return {JQueryObject|boolean}
   */
  var addGroup_ = function(canvas, group, data) {
    var $groupRow = false;

    // Loop through sources to add statistics data to the group.
    data[0]["sources"].forEach(function(source) {
      if (source.group_name !== group.name) return;

      var total = source.metrics.total;
      if (total === 0) { return; };

      // Only add the group row the first time
      if (!$groupRow) {
        $groupRow = getgroupRow_(canvas, group);
      }

      // Flag that there is at least one metric
      metricsFound_ = true;

      // Some sources have multiple data
      if (source.group_name === "viewed") {
        if (source.metrics.html > 0) addSource_(source, source.display_name + " HTML", source.metrics.html, group, "html", $groupRow);
        if (source.metrics.pdf > 0) addSource_(source, source.display_name + " PDF", source.metrics.pdf, group, "pdf", $groupRow);
      } else {
        var label = source.display_name;
        addSource_(source, label, total, group, "total", $groupRow);
      }
    });
  };


  /**
   * Get group row d3 HTML element. It will automatically
   * add the element to the passed canvas.
   * @param {d3Object} canvas d3 HTML element
   * @param {Array} group group information.
   * @param {d3Object}
   */
  var getgroupRow_ = function(canvas, group) {
    var groupRow, groupTitle, tooltip;

    // Build group html objects.
    groupRow = canvas.append("div")
      .attr("class", "alm-group")
      .attr("id", "group-" + group.name);

    return groupRow;
  };


  /**
   * Add source information to the passed group row element.
   * @param {Object} source
   * @param {integer} sourceTotalValue
   * @param {Object} group
   * @param {JQueryObject} $groupRow
   * @return {JQueryObject}
   */
  var addSource_ = function(source, label, sourceTotalValue, group, subgroup, $groupRow) {
    var $row, $countLabel, $count,
        total = sourceTotalValue;

    $row = $groupRow
      .append("div")
      .attr("class", "alm-source")
      .attr("id", "source-" + source.name + "-" + subgroup);
    $countLabel = $row.append("div")
      .attr("class", "alm-label " + group.name);

    if (source.events_url) {
      // if there is an events_url, we can link to it from the count
      $count = $countLabel.append("p")
        .attr("class", "alm-count")
        .attr("id", "alm-count-" + source.name + "-" + group.name)
        .append("a")
        .attr("href", function(d) { return source.events_url; });
    } else {
      // if no events_url, we just put in the count
      $count = $countLabel.append("p")
        .attr("class", "alm-count")
        .attr("id", "alm-count-" + source.name + "-" + group.name);
    }

    $count
      .text(formatNumber_(total));

    if (source.name === 'pkpTimedViews') {
      $countLabel.append("p")
        .text(label);
    } else {
      // link the source name
      $countLabel.append("p").append("a")
        .attr("href", baseUrl_ + "/sources/" + source.name)
        .text(label);
    }

    // Only add a chart if the browser supports SVG
    if (hasSVG_) {
      var level = false;

      // check what levels we can show
      var showDaily = false;
      var showMonthly = false;
      var showYearly = false;

      if (source.by_year) {
        var level_data = getData_('year', source);
        var yearTotal = level_data.reduce(function(i, d) { return i + d[subgroup]; }, 0);
        var numYears = d3.time.year.utc.range(pub_date, new Date()).length;

        if (yearTotal >= minItems_.minEventsForYearly &&
          numYears >= minItems_.minYearsForYearly) {
          showYearly = true;
          level = 'year';
        }
      }

      if (source.by_month) {
        var level_data = getData_('month', source);
        var monthTotal = level_data.reduce(function(i, d) { return i + d[subgroup]; }, 0);
        var numMonths = d3.time.month.utc.range(pub_date, new Date()).length;

        if (monthTotal >= minItems_.minEventsForMonthly &&
            numMonths >= minItems_.minMonthsForMonthly) {
            showMonthly = true;
            level = 'month';
        }
      }

      if (source.by_day){
        var level_data = getData_('day', source);
        var dayTotal = level_data.reduce(function(i, d) { return i + d[subgroup]; }, 0);
        var numDays = d3.time.day.utc.range(pub_date, new Date()).length;

        if (dayTotal >= minItems_.minEventsForDaily && numDays >= minItems_.minDaysForDaily) {
            showDaily = true;
            level = 'day';
        }
      }

      // The level and level_data should be set to the finest level
      // of granularity that we can show
      timeInterval = getTimeInterval_(level);

      // check there is data for
      if (showDaily || showMonthly || showYearly) {
        $row
          .attr('class', 'alm-source with-chart');

        var $chartDiv = $row.append("div")
          .attr("class", "alm-chart");

        var viz = getViz_($chartDiv, source, group, subgroup);
        loadData_(viz, level);

        var update_controls = function(control) {
            control.siblings('.alm-control').removeClass('active');
            control.addClass('active');
        };

        var $levelControlsDiv = $chartDiv.append("div")
          .attr("class", "alm-control-label")
          .attr("style", "width: " + (viz.margin.left + viz.width) + "px;");

        if (showDaily) {
          $levelControlsDiv.append("a")
            .attr("href", "javascript:void(0)")
            .classed("alm-control", true)
            .classed("disabled", !showDaily)
            .classed("active", (level === 'day'))
            .text("daily (first 30)")
            .on("click", function() {
              if (showDaily && !$(this).hasClass('active')) {
                loadData_(viz, 'day');
                update_controls($(this));
              }
            }
          );

          $levelControlsDiv.append("text").text(" | ");
        }

        if (showMonthly) {
          $levelControlsDiv.append("a")
            .attr("href", "javascript:void(0)")
            .classed("alm-control", true)
            .classed("disabled", !showMonthly || !showYearly)
            .classed("active", (level == 'month'))
            .text("monthly")
            .on("click", function() { if (showMonthly && !$(this).hasClass('active')) {
              loadData_(viz, 'month');
              update_controls($(this));
            } });

          if (showYearly) {
            $levelControlsDiv.append("text")
              .text(" | ");
          }

        }

        if (showYearly) {
          $levelControlsDiv.append("a")
            .attr("href", "javascript:void(0)")
            .classed("alm-control", true)
            .classed("disabled", !showYearly || !showMonthly)
            .classed("active", (level === 'year'))
            .text("yearly")
            .on("click", function() {
              if (showYearly && !$(this).hasClass('active')) {
                loadData_(viz, 'year');
                update_controls($(this));
              }
            }
          );
        }
      };
    };

    return $row;
  };


  /**
   * Extract the date from the source
   * @param level (day|month|year)
   * @param d the datum
   * @return {Date}
   */
  var getDate_ = function(level, d) {
    switch (level) {
      case 'year':
        return new Date(d.year, 0, 1);
      case 'month':
        // js Date indexes months at 0
        return new Date(d.year, d.month - 1, 1);
      case 'day':
        // js Date indexes months at 0
        return new Date(d.year, d.month - 1, d.day);
    }
  };


  /**
   * Format the date for display
   * @param level (day|month|year)
   * @param d the datum
   * @return {String}
   */
  var getFormattedDate_ = function(level, d) {
    switch (level) {
      case 'year':
        return d3.time.format("%Y")(getDate_(level, d));
      case 'month':
        return d3.time.format("%b %y")(getDate_(level, d));
      case 'day':
        return d3.time.format("%d %b %y")(getDate_(level, d));
    }
  };


  /**
   * Extract the data from the source.
   * @param {string} level (day|month|year)
   * @param {Object} source
   * @return {Array} Metrics
   */
  var getData_ = function(level, source) {
    switch (level) {
      case 'year':
        return source.by_year;
      case 'month':
        return source.by_month;
      case 'day':
        return source.by_day;
    }
  };

  /**
   * Returns a d3 timeInterval for date operations.
   * @param {string} level (day|month|year
   * @return {Object} d3 time Interval
   */
  var getTimeInterval_ = function(level) {
    switch (level) {
      case 'year':
        return d3.time.year.utc;
      case 'month':
        return d3.time.month.utc;
      case 'day':
        return d3.time.day.utc;
    }
  };

  /**
   * The basic general set up of the graph itself
   * @param {JQueryElement} chartDiv The div where the chart should go
   * @param {Object} source
   * @param {Array} group The group for 86 chart
   * @return {Object}
   */
  var getViz_ = function(chartDiv, source, group, subgroup) {
    var viz = {};

    // size parameters
    viz.margin = {top: 10, right: 20, bottom: 5, left: 50};
    viz.width = 760 - viz.margin.left - viz.margin.right;
    viz.height = 115 - viz.margin.top - viz.margin.bottom;

    // div where everything goes
    viz.chartDiv = chartDiv;

    // source data and which group
    viz.group = group;
    viz.subgroup = subgroup;
    viz.source = source;

    // just for record keeping
    viz.name = source.name + '-' + group.name + '-' + viz.subgroup;

    viz.x = d3.time.scale();
    viz.x.range([0, viz.width]);

    viz.y = d3.scale.linear();
    viz.y.range([viz.height, 0]);

    viz.z = d3.scale.ordinal();
    viz.z.range([group.name, group.name + '-alt']);

    // the chart
    viz.svg = viz.chartDiv.append("svg")
      .attr("width", viz.width + viz.margin.left + viz.margin.right)
      .attr("height", viz.height + viz.margin.top + viz.margin.bottom + 1)
      .append("g")
      .attr("transform", "translate(" + viz.margin.left + "," + viz.margin.top + ")");

    // draw the bars g first so it ends up underneath the axes
    viz.bars = viz.svg.append("g");

    // and the shadow bars on top for the tooltips
    viz.barsForTooltips = viz.svg.append("g");

    viz.svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + viz.height + ")");

    viz.svg.append("g")
      .attr("class", "y axis");

    return viz;
  };


  /**
   * Takes in the basic set up of a graph and loads the data itself
   * @param {Object} viz AlmViz object
   * @param {string} level (day|month|year)
   */
  var loadData_ = function(viz, level) {
    var group = viz.group;
    var subgroup = viz.subgroup;
    var level_data = getData_(level, viz.source);
    var timeInterval = getTimeInterval_(level);

    var end_date = new Date();
    // use only first 29 days if using day view
    // close out the year otherwise
    if (level == 'day') {
      end_date = timeInterval.offset(pub_date, 29);
    } else {
      end_date = d3.time.year.utc.ceil(end_date);
    }

    //
    // Domains for x and y
    //
    // a time x axis, between pub_date and end_date
    viz.x.domain([timeInterval.floor(pub_date), end_date]);

    // a linear axis from 0 to max value found
    viz.y.domain([0, d3.max(level_data, function(d) { return d[subgroup]; })]);

    //
    // Axis
    //
    // a linear axis between publication date and current date
    viz.xAxis = d3.svg.axis()
      .scale(viz.x)
      .tickSize(0)
      .ticks(0);

    // a linear y axis between 0 and max value found in data
    viz.yAxis = d3.svg.axis()
      .scale(viz.y)
      .orient("left")
      .tickSize(0)
      .tickValues([d3.max(viz.y.domain())])   // only one tick at max
      .tickFormat(d3.format(",d"));

    //
    // The chart itself
    //

    // TODO: these transitions could use a little work

    // add more padding to wider bars
    var rawWidth = (viz.width/(timeInterval.range(pub_date, end_date).length + 1));
    var barWidth = Math.max(rawWidth - rawWidth/5, 1);

    var barsForTooltips = viz.barsForTooltips.selectAll(".barsForTooltip")
      .data(level_data, function(d) { return getDate_(level, d); });

    barsForTooltips
      .exit()
      .remove();

    var bars = viz.bars.selectAll(".bar")
      .data(level_data, function(d) { return getDate_(level, d); });

    bars
      .enter().append("rect")
      .attr("class", function(d) { return "bar " + viz.z((level == 'day' ? d3.time.weekOfYear(getDate_(level, d)) : d.year)); })
      .attr("y", viz.height)
      .attr("height", 0);

    bars
      .attr("x", function(d) { return viz.x(getDate_(level, d)) + 2; })
      .attr("width", barWidth);

    bars.transition()
      .duration(1000)
      .attr("width", barWidth)
      .attr("y", function(d) { return viz.y(d[subgroup]); })
      .attr("height", function(d) { return viz.height - viz.y(d[subgroup]); });

    bars
      .exit().transition()
      .attr("y", viz.height)
      .attr("height", 0);

    bars
      .exit()
      .remove();

    viz.svg
      .select(".x.axis")
      .call(viz.xAxis);

    viz.svg
      .transition().duration(1000)
      .select(".y.axis")
      .call(viz.yAxis);

    barsForTooltips
      .enter().append("rect")
      .attr("class", function(d) { return "barsForTooltip " + viz.z((level === 'day' ? d3.time.weekOfYear(getDate_(level, d)) : d.year)); });

    barsForTooltips
      .attr("width", barWidth + 2)
      .attr("x", function(d) { return viz.x(getDate_(level, d)) + 1; })
      .attr("y", function(d) { return viz.y(d[subgroup]) - 1; })
      .attr("height", function(d) { return viz.height - viz.y(d[subgroup]) + 1; });

    // add in some tool tips
    viz.barsForTooltips.selectAll("rect").each(
      function(d){
        $(this).tooltip('destroy'); // need to destroy so all bars get updated
        $(this).tooltip({title: formatNumber_(d[subgroup]) + " in " + getFormattedDate_(level, d), container: "body"});
      }
    );
  };
}
