/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === "") { page = 1; }
  var per_page = params.attr('data-per-page');
  var contributor_id = params.attr('data-contributor-id');
  var source_id = params.attr('data-source-id');
  var sort = params.attr('data-sort');

  var query = encodeURI("/api/contributors/" + contributor_id + "/contributions?page=" + page);
  if (per_page !== "") { query += "&per_page=" + per_page; }
  if (source_id !== "") { query += "&source_id=" + source_id; }
  if (sort !== "") { query += "&sort=" + sort; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, query)
  .await(function(error, s, c) {
    if (error) { return console.warn(error); }
    contributionsViz(c, s.sources);
    paginate(c, "#content");
});

// add data to page
function contributionsViz(json, sources) {
  data = json.contributions;

  json.href = "?page={{number}}";
  if (source_id !== "") { json.href += "&source_id=" + source_id; }
  if (sort !== "") { json.href += "&sort=" + sort; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no works");
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
      .attr("href", function() { return "/works/" + pathForWork(work.work_id); })
      .html(work.title);
    d3.select("#results").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results").append("a")
      .attr("href", function() { return work.work_id; })
      .text(work.work_id);
    d3.select("#results").append("p")
      .text(signpostsToString(work, sources, source_id, sort));
  }
}
