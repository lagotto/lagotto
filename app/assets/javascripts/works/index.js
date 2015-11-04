/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === "") { page = 1; }
  var per_page = params.attr('data-per-page');
  var q = params.attr('data-q');
  var class_name = params.attr('data-class-name');
  var publisher_id = params.attr('data-publisher-id');
  var contributor_id = params.attr('data-contributor-id');
  var source_id = params.attr('data-source-id');
  var sort = params.attr('data-sort');
  var model = params.attr('data-model');

  var query = encodeURI("/api/works?page=" + page);
  if (per_page !== "") { query += "&per_page=" + per_page; }
  if (q !== "") { query += "&q=" + q; }
  if (class_name !== "") { query += "&class_name=" + class_name; }
  if (publisher_id !== "") { query += "&publisher_id=" + publisher_id; }
  if (contributor_id !== "") { query += "&contributor_id=" + contributor_id; }
  if (source_id !== "") { query += "&source_id=" + source_id; }
  if (sort !== "") { query += "&sort=" + sort; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, query)
  .await(function(error, s, w) {
    if (error) { return console.warn(error); }
    worksViz(w, s.sources);
    if (model !== "sources") { paginate(w, "#content"); }
});

// add data to page
function worksViz(json, sources) {
  data = json.works;

  json.href = "?page={{number}}";
  if (q !== "") { json.href += "&q=" + q; }
  if (class_name !== "") { json.href += "&class_name=" + class_name; }
  if (publisher_id !== "" && model !== "publishers") { json.href += "&publisher_id=" + publisher_id; }
  if (contributor_id !== "" && model !== "contributors") { json.href += "&contributor_id=" + contributor_id; }
  if (source_id !== "") { json.href += "&source_id=" + source_id; }
  if (sort !== "") { json.href += "&sort=" + sort; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no works");
    if (model === "sources") { d3.select("div#rss").remove(); }
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
      .attr("href", function() { return "/works/" + pathForWork(work.id); })
      .html(work.title);
    d3.select("#results").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results").append("a")
      .attr("href", function() { return work.id; })
      .text(work.id);
    d3.select("#results").append("p")
      .text(signpostsToString(work, sources, source_id, sort));
  }
}
