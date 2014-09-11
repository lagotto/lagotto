// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var uid_type = params.attr('data-uid_type');
  var uid = params.attr('data-uid');
  var query = encodeURI("/api/v5/articles?api_key=" + api_key + "&ids=" + uid + "&type=" + uid_type + "&info=detail");
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
  data = data.map( function(d) { return d.events_csl });
  data = d3.merge(data);

  if (data.length == 0) {
    d3.select("#results").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("No events found");
    return;
  }

  // generate iso8601 datetime for sorting, year for nesting
  data = data.map(function(d) {
    d["date"] = datePartsToDate(d["issued"]["date-parts"][0]);
    d["year"] = (d["date"]) ? d["date"].getUTCFullYear() : null;
    return d;
  });

  data = data.filter(function(d) { return d.year !== null });

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
    year = nest_by_year[i];

    d3.select("#results").append("h2")
      .append("text")
      .text(year.key);

    for (var j=0; j<year.values.length; j++) {
      var event = year.values[j];
      var event_text =
        (event["author"].length > 0 ? formattedAuthor(event["author"]) + ". " : "") +
        (event["container-title"].length > 0 ? "<em>" + event["container-title"] + "</em>. " : "") +
        formattedType(event["type"]) + ". " +
        formattedDate(event["date"], event["issued"]["date-parts"][0].length)  + ". ";

      var sel_title = d3.select("#results").append("h4")
        .attr("class", "article")
        .append("text")
        .html(event["title"]);

      sel_title.classed('discussed_event', function(d) { return event["type"] != "article-journal"; });

      d3.select("#results").append("p")
        .html(event_text)
        .append("a")
        .attr("href", function(d) { return event["url"]; })
        .append("text")
        .text(event["url"]);
    };
  };

  paginate(data, page);
}

// pagination
function paginate(data, page) {
  if (data.length > 50) {
    var total = Math.ceil(data.length/50);
    var max_visible = 10;
    var href = "#events?page={{number}}";
    var prev = (page > 1) ? "«" : null;
    var next = (page < total) ? "»" : null;

    d3.select("#results").append("div")
      .attr("id", "paginator");

    $('#paginator').bootpag({
      total: total,
      page: page,
      maxVisible: max_visible,
      href: href,
      leaps: false,
      prev: prev,
      next: next
    }).on("page", function(event, num) {
      showEvents(data, num);
    });
  }
}

// d3 helper functions
 var formatDate = d3.time.format("%B %d, %Y"),
     formatMonthYear = d3.time.format("%B %Y"),
     formatYear = d3.time.format("%Y");

// construct date object from date parts
function datePartsToDate(date_parts) {
  var len = date_parts.length;

  // not in expected format
  if (len == 0 || len > 3) return null;

  // turn numbers to strings and pad with 0
  for (i = 0; i < len; ++i) {
    if (date_parts[i] < 10) {
      date_parts[i] = "0" + date_parts[i];
    } else {
      date_parts[i] = "" + date_parts[i];
    }
  }

  // convert to date, workaround for different time zones
  var timestamp = Date.parse(date_parts.join('-') + 'T12:00');
  return new Date(timestamp);
}

// format date
function formattedDate(date, len) {
  switch (len) {
    case 1:
      return formatYear(date);
    case 2:
      return formatMonthYear(date);
    case 3:
      return formatDate(date);
  }
}

// construct author object from author parts
function formattedAuthor(author) {
  author = author.map(function(d) { return d.given + " " + d.family; });
  switch (author.length) {
    case 0:
    case 1:
    case 2:
      return author.join(" & ");
    case 3:
    case 4:
      return author.slice(0,-1).join(", ") + " & " + author[author.length - 1];
    default:
      return author.slice(0,3).join(", ") + ", <em>et al</em>";
  }
}

// format event type
function formattedType(type) {
  var types = { "article-journal": "Journal article",
                "article-newspaper": "News",
                "post": "Blog post",
                "webpage": "Web page",
                "broadcast": "Podcast/Video",
                "personal_communication": "Personal communication" }
  return types[type] || "Other";
}
