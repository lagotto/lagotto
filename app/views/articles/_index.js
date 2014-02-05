var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');
var page = d3.select("h1#api_key").attr('data-page');
var q = d3.select("h1#api_key").attr('data-q');
var class_name = d3.select("h1#api_key").attr('data-class_name');
var order = d3.select("h1#api_key").attr('data-order');
var query = "/api/v5/articles?api_key=" + api_key;
if (page != "") query += "&page=" + page;
if (q != "") query += "&q=" + q;
if (class_name != "") query += "&class_name=" + class_name;
if (order != "") {
  query += "&source=" + order + "&order=" + order;
} else {
  query += "&info=summary";
}

d3.json(query, function(error, json) {
  data = json["data"];

  json["href"] = "?page={{number}}";
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

  var formatDate = d3.time.format("%B %d, %Y");
  var formatFixed = d3.format(",.0f");

  for (var i=0; i<data.length; i++) {
    article = data[i];

    d3.select("#results").append("h4")
      .attr("class", "article")
      .append("a")
      .attr("href", function(d) { return "/articles/info:doi/" + article["doi"]; })
      .append("text")
      .text(article["title"]);
    d3.select("#results").append("p")
      .text(iso8601ToDate(article["publication_date"]) + ". ")
      .append("a")
      .attr("href", function(d) { return "http://dx.doi.org/" + article["doi"]; })
      .append("text")
      .text("http://dx.doi.org/" + article["doi"]);
    d3.select("#results").append("p")
      .text(signpostsToString(article));
  };

  // Pagination
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

  function iso8601ToDate(iso8601_string) {
    date = new Date(iso8601_string);
    return formatDate(date).replace(/\b0(?=\d)/g, '');
  }

  function signpostsToString(article) {
    var arr = []
    if (order != "") {
      source = article["sources"].filter(function(d) { return d.name == order })[0];
      str = source.display_name + ": " + source.metrics.total;
    } else {
      str = "";
    }
    if (article["viewed"] > 0) arr.push("Viewed: " + formatFixed(article["viewed"]));
    if (article["cited"] > 0) arr.push("Cited: " + formatFixed(article["cited"]));
    if (article["saved"] > 0) arr.push("Saved: " + formatFixed(article["saved"]));
    if (article["discussed"] > 0) arr.push("Discussed: " + formatFixed(article["discussed"]));
    if (arr.length > 0) {
      return str + " | " + arr.join(" • ") + ". ";
    } else {
      return str;
    }
  }
});