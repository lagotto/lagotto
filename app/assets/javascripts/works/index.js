// construct query string
var params = d3.select("#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var page = params.attr('data-page');
  var per_page = params.attr('data-per_page');
  var q = params.attr('data-q');
  var class_name = params.attr('data-class_name');
  var publisher_id = params.attr('data-publisher_id');
  var source_id = params.attr('data-source_id');
  var order = params.attr('data-order');
  var model = params.attr('data-model');

  var query = encodeURI("/api/v5/articles?api_key=" + api_key);
  if (page != "") query += "&page=" + page;
  if (per_page != "") query += "&per_page=" + per_page;
  if (q != "") query += "&q=" + q;
  if (class_name != "") query += "&class_name=" + class_name;
  if (publisher_id != "") query += "&publisher_id=" + publisher_id;
  if (source_id != "") query += "&source_id=" + source_id;
  if (order != "") query += "&order=" + order;
  if (source_id == "" && order == "") {
    query += "&info=summary";
  }
};

// load the data from the Lagotto API
if (query) {
  d3.json(query, function(error, json) {
    if (error) { return console.warn(error); }
    worksViz(json);
    paginate(json);
  });
}

// add data to page
function worksViz(json) {
  data = json["data"];

  json["href"] = "?page={{number}}";
  if (q != "") json["href"] += "&q=" + q;
  if (class_name != "") json["href"] += "&class_name=" + class_name;
  if (publisher_id != "" && model != "publisher") json["href"] += "&publisher_id=" + publisher_id;
  if (source_id != "") json["href"] += "&source_id=" + source_id;
  if (order != "") json["href"] += "&order=" + order;

  d3.select("#loading-results").remove();

  if (data.length == 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("No works found");
    if (page == "") d3.select("div#rss").remove();
    return;
  }

  d3.select("#content").insert("div")
    .attr("id", "results");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var date_parts = work["issued"]["date-parts"][0];
    var date = datePartsToDate(date_parts);

    d3.select("#results").append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function(d) { return "/works/" + work["id"]; })
      .html(work["title"]);
    d3.select("#results").append("p")
      .text(formattedDate(date, date_parts.length) + ". ")
      .append("a")
      .attr("href", function(d) { return url_for(work); })
      .append("text")
      .text(url_for(work));
    d3.select("#results").append("p")
      .text(signpostsToString(work));
  };
};

// link to individual work
function url_for(work) {
  if (!!work["doi"]) {
    return "http://dx.doi.org/" + work["doi"];
  } else if (!!work["pmid"]) {
    return "http://www.ncbi.nlm.nih.gov/pubmed/" + work["pmid"];
  } else if (!!work["pmcid"]) {
    return "http://www.ncbi.nlm.nih.gov/pmc/works/PMC" + work["pmcid"];
  } else if (!!work["canonical_url"]) {
    return work["canonical_url"];
  } else {
    return ""
  }
};

// pagination
function paginate(json) {
  if ((page != "") & json["total_pages"] > 1) {
    var prev = (json["page"] > 1) ? "«" : null;
    var next = (json["page"] < json["total_pages"]) ? "»" : null;

    d3.select("#content").append("div")
      .attr("id", "paginator")
      .attr("class", "text-center");

    $('#paginator').bootpag({
      total: json["total_pages"],
      page: json["page"],
      maxVisible: 10,
      href: json["href"],
      leaps: false,
      prev: prev,
      next: next
    });
  }
};

// d3 helper functions
 var formatDate = d3.time.format("%B %d, %Y"),
     formatMonthYear = d3.time.format("%B %Y"),
     formatYear = d3.time.format("%Y"),
     formatFixed = d3.format(",.0f");

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
};

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
};

function signpostsToString(work) {
  if (source_id != "") {
    s = work["sources"].filter(function(d) { return d.name == source_id })[0];
    a = [s.display_name + ": " + formatFixed(s.metrics.total)];
  } else if (order != "") {
    s = work["sources"].filter(function(d) { return d.name == order })[0];
    a = [s.display_name + ": " + formatFixed(s.metrics.total)];
  } else {
    a = [];
  }
  var b = []
  if (work["viewed"] > 0) b.push("Viewed: " + formatFixed(work["viewed"]));
  if (work["cited"] > 0) b.push("Cited: " + formatFixed(work["cited"]));
  if (work["saved"] > 0) b.push("Saved: " + formatFixed(work["saved"]));
  if (work["discussed"] > 0) b.push("Discussed: " + formatFixed(work["discussed"]));
  if (b.length > 0) {
    a.push(b.join(" • "));
    return a.join(" | ");
  } else {
    return a;
  }
};
