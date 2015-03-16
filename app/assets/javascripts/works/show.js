/*global d3 */

var formatDate = d3.time.format("%B %d, %Y"),
    formatMonthYear = d3.time.format("%B %Y"),
    formatYear = d3.time.format("%Y"),
    params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var pid_type = params.attr('data-pid_type');
  var pid = params.attr('data-pid');
  var query = encodeURI("/api/v5/articles?api_key=" + api_key + "&ids=" + pid + "&type=" + pid_type + "&info=detail");
}

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;

    eventViz(data);
  });
}

// add data to page
function eventViz(data) {
  d3.select("#loading-events").remove();

  var data = data[0]['sources'];
  data = data.map( function(d) { return d.events_csl; });
  data = d3.merge(data);

  if (data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("No formatted events found");
    return;
  }

  d3.select("#content").insert("div")
    .attr("id", "results");

  // remove duplicate events based on URL
  data = _.uniq(data, "url");

  // generate iso8601 datetime for sorting, year for nesting
  data = data.map(function(d) {
    d.date = datePartsToDate(d["issued"]["date-parts"][0]);
    d.year = (d.date) ? d.date.getUTCFullYear() : null;
    return d;
  });

  data = data.filter(function(d) { return d.year !== null; });

  var page = 1;
  showEvents(data, page);
}

function showEvents(data, page) {
  data = data.sort(function(a, b) { return d3.descending(a.date, b.date); });

  var per_page = 50;
  var start = (page - 1) * per_page;
  var end = start + per_page;
  var paged_data = data.slice(start, end);

  d3.select("#results").html("");

  var nest_by_year = d3.nest()
    .key(function(d) { return d.year; })
    .sortKeys(d3.descending)
    .sortValues(function(a, b) { return d3.descending(a.date, b.date); })
    .entries(paged_data);

  for (var i=0; i<nest_by_year.length; i++) {
    var year = nest_by_year[i];

    d3.select("#results").append("h2")
      .append("text")
      .text(year.key);

    for (var j=0; j<year.values.length; j++) {
      var event = year.values[j];
      var event_text =
        (event.author.length > 0 ? formattedAuthor(event.author) + ". " : "") +
        (event["container-title"].length > 0 ? "<em>" + event["container-title"] + "</em>. " : "") +
        formattedType(event.type) + ". " +
        formattedDate(event.date, event["issued"]["date-parts"][0].length)  + ". ";

      var sel_title = d3.select("#results").append("h4")
        .attr("class", "work")
        .append("text")
        .html(event.title);

      sel_title.classed('discussed_event', function() { return event.type !== "article-journal"; });

      d3.select("#results").append("p")
        .html(event_text)
        .append("a")
        .attr("href", function() { return event.url; })
        .append("text")
        .text(event.url);
    }
  }
  paginate_events(data, page);
}
