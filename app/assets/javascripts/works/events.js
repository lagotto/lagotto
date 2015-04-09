/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var event_id = params.attr('data-pid');
  var api_key = params.attr('data-api_key');
  var page = params.attr('data-page');
  if (page === "") { page = 1; }
  var per_page = params.attr('data-per_page');
  var source_id = params.attr('data-source_id');
  var sort = params.attr('data-sort');

  var query = encodeURI("/api/works/" + event_id + "/events?page=" + page);
  if (per_page !== "") { query += "&per_page=" + per_page; }
  if (source_id !== "") { query += "&source_id=" + source_id; }
  if (sort !== "") { query += "&sort=" + sort; }
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/vnd.lagotto+json; version=6")
    .header("Authorization", "Token token=" + api_key)
    .get(function(error, json) {
      if (error) { return console.warn(error); }
        eventsViz(json);
        paginate(json);
  });
}

// add data to page
function eventsViz(json) {
  data = json.events;

  json.href = "?page={{number}}";
  if (source_id !== "") { json.href += "&source_id=" + source_id; }
  if (sort !== "") { json.href += "&sort=" + sort; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content-events").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no events");
    return;
  }

  d3.select("#content-events").insert("div")
    .attr("id", "results");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var date_parts = work["issued"]["date-parts"][0];
    var date = datePartsToDate(date_parts);

    d3.select("#results").append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + work.id; })
      .html(work.title);
    d3.select("#results").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results").append("a")
      .attr("href", function() { return urlForWork(work); })
      .text(urlForWork(work));
    d3.select("#results").append("p")
      .text(signpostsToString(work));
  }
}
