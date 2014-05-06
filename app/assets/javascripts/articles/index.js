// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var uid_type = params.attr('data-uid_type');
  var page = params.attr('data-page');
  var q = params.attr('data-q');
  var class_name = params.attr('data-class_name');
  var order = params.attr('data-order');

  var query = encodeURI("/api/v5/articles?api_key=" + api_key);
  if (page != "") query += "&page=" + page;
  if (q != "") query += "&q=" + q;
  if (class_name != "") query += "&class_name=" + class_name;
  if (order != "") {
    query += "&source=" + order + "&order=" + order;
  } else {
    query += "&info=summary";
  }
};

// load the data from the ALM API
if (query) {
  d3.json(query, function(error, json) {
    if (error) return console.warn(error);
    articlesViz(json);
    paginate(json);
  });
}

// add data to page
function articlesViz(json) {
  data = json["data"];

  json["href"] = "?page={{number}}";
  if (q != "") json["href"] += "&q=" + q;
  if (class_name != "") json["href"] += "&class_name=" + class_name;
  if (order != "") json["href"] += "&order=" + order;

  if (data.length == 0) {
    d3.select("#results").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("No articles found");
    if (page == "") d3.select("div#rss").remove();
    return;
  }

  for (var i=0; i<data.length; i++) {
    article = data[i];

    d3.select("#results").append("h4")
      .attr("class", "article")
      .append("a")
      .attr("href", function(d) { return "/articles/info:" + uid_type + "/" + article[uid_type]; })
      .text(article["title"]);
    d3.select("#results").append("p")
      .text(datePartsToDate(article["issued"]["date_parts"]) + ". ")
      .append("a")
      .attr("href", function(d) { return url_for(article); })
      .append("text")
      .text(url_for(article));
    d3.select("#results").append("p")
      .text(signpostsToString(article));
  };
};

// link to individual article
function url_for(article) {
  switch (uid_type) {
  case 'doi':
    return "http://dx.doi.org/" + article["doi"];
  case 'pmid':
    return "http://www.ncbi.nlm.nih.gov/pubmed/" + article["pmid"];
  case 'pmcid':
    return "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC" + article["pmcid"];
  }
};

// pagination
function paginate(json) {
  if ((page != "") & json["total_pages"] > 1) {
    d3.select("#results").append("div")
      .attr("id", "paginator");

    $('#paginator').bootpag({
      total: json["total_pages"],
      page: json["page"],
      maxVisible: 10,
      href: json["href"]
    });
  }
};

// d3 helper functions
 var formatDate = d3.time.format("%B %d, %Y"),
     formatMonthYear = d3.time.format("%B %Y"),
     formatFixed = d3.format(",.0f");

// Construct date object from date parts and format acccordingly
function datePartsToDate(date_parts) {
  var len = date_parts.length;

  // not in expected format
  if (len == 0 || len > 3) return null;

  // turn numbers to strings and pad with 0
  for (i = 0; i < date_parts.length; ++i) {
   if (date_parts[i] < 10) {
      date_parts[i] = "0" + date_parts[i];
    } else {
      date_parts[i] = "" + date_parts[i];
    }
  }

  // year only, no formatting needed
  if (len == 1) return date_parts[0];

  // convert to date, then format
  // workaround for different time zones
  var timestamp = Date.parse(date_parts.join('-') + 'T12:00');
  var date = new Date(timestamp);

  if (len == 3) {
    return formatDate(date);
  } else {
    return formatMonthYear(date);
  }
};

function signpostsToString(article) {
  if (order != "") {
    source = article["sources"].filter(function(d) { return d.name == order })[0];
    a = [source.display_name + ": " + formatFixed(source.metrics.total)];
  } else {
    a = [];
  }
  var b = []
  if (article["viewed"] > 0) b.push("Viewed: " + formatFixed(article["viewed"]));
  if (article["cited"] > 0) b.push("Cited: " + formatFixed(article["cited"]));
  if (article["saved"] > 0) b.push("Saved: " + formatFixed(article["saved"]));
  if (article["discussed"] > 0) b.push("Discussed: " + formatFixed(article["discussed"]));
  if (b.length > 0) {
    a.push(b.join(" • "));
    return a.join(" | ");
  } else {
    return a;
  }
};
