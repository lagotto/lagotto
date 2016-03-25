/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var q = params.attr('data-q');
  var class_name = params.attr('data-class-name');
  var publisher_id = params.attr('data-publisher-id');
  var contributor_id = params.attr('data-contributor-id');
  var source_id = params.attr('data-source-id');
  var sort = params.attr('data-sort');
  var model = params.attr('data-model');

  var query = encodeURI("/api/works?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (q !== null) { query += "&q=" + q; }
  if (class_name !== null) { query += "&class_name=" + class_name; }
  if (publisher_id !== null) { query += "&publisher_id=" + publisher_id; }
  if (contributor_id !== null) { query += "&contributor_id=" + contributor_id; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (sort !== null) { query += "&sort=" + sort; }
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
  if (q !== null) { json.href += "&q=" + q; }
  if (class_name !== null) { json.href += "&class_name=" + class_name; }
  if (publisher_id !== null && model !== "publishers") { json.href += "&publisher_id=" + publisher_id; }
  if (contributor_id !== null && model !== "contributors") { json.href += "&contributor_id=" + contributor_id; }
  if (source_id !== null) { json.href += "&source_id=" + source_id; }
  if (sort !== null) { json.href += "&sort=" + sort; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no works");
    if (model === "sources") { d3.select("div#rss").remove(); }
    return;
  }

  d3.select("#content").insert("h4")
    .attr("class", "results")
    .text(numberWithDelimiter(json.meta.total) + " Results");

  d3.select("#work-sort").classed("hidden", false);

  for (var i=0; i<data.length; i++) {
    var work = data[i];

    d3.select("#content").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-" + i).insert("div")
      .attr("class", "panel-body")
      .attr("id", "panel-body-" + i);

    d3.select("#panel-body-" + i).append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.id); })
      .html(work.title);
    d3.select("#panel-body-" + i).append("p")
      .html(formattedAuthor(work.author)).append("p")
      .html(metadataToString(work));
    d3.select("#panel-body" + i).append("p")
      .text(signpostsToString(work, sources, source_id, sort));

    d3.select("#panel-" + i).insert("div")
      .attr("class", "panel-footer").append("a")
      .attr("href", function() { return work.id; })
      .html(work.id);
  }
}
