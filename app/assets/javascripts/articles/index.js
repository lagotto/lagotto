// construct query string
var params = d3.select("h1#api_key");
if (params.empty()) throw "Missing id #api_key";

var api_key = params.attr('data-api_key');
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
} else {
    query += "&info=summary";
}

// load the data from the ALM API
d3.json(query, function(error, json) {
    if (error) return console.warn(error);
    articlesViz(json);
});

// add data to page
function articlesViz(json) {

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

    for (var i=0; i<data.length; i++) {
        article = data[i];

        d3.select("#results").append("h4")
            .attr("class", "article")
            .append("a")
            .attr("href", function(d) { return "/articles/info:doi/" + article["doi"]; })
            .text(article["title"]);
        d3.select("#results").append("p")
            .text(datePartsToDate(article["issued"]["date_parts"]) + ". ")
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
};

// d3 helper functions
var formatDate = d3.time.format("%B %d, %Y"),
    formatMonthYear = d3.time.format("%B %Y"),
    formatYear = d3.time.format("%Y"),
    formatFixed = d3.format(",.0f");

// Construct date object from date parts and format acccordingly
// We are using "1" for missing day and month, but don't display them
function datePartsToDate(date_parts) {
    len = date_parts.length;
    while (date_parts.length < 3) date_parts.push(1);
        date = new Date(date_parts);
        if (len == 3) {
        return formatDate(date);
    } else if (len == 2) {
        return formatMonthYear(date);
    } else {
        return formatYear(date);
    }
};

function signpostsToString(article) {
    if (order != "") {
        source = article["sources"].filter(function(d) { return d.name == order })[0];
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
