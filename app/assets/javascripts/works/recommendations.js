/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var work_id = params.attr('data-pid');
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var source_id = params.attr('data-source-id');
  var sort = params.attr('data-sort');
  var relation_type_id = params.attr('data-relation-type-id');

  var query = encodeURI("/api/works/" + pathForWork(work_id) + "/recommendations?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (relation_type_id !== null) { query += "&relation_type_id=" + relation_type_id; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/relation_types"))
  .defer(d3.json, query)
  .await(function(error, s, r, w) {
    if (error) { return console.warn(error); }
    recommendationsViz(w, s.sources, r.relation_types);
    paginate(w, "#content-recommendations");
});

// add data to page
function recommendationsViz(json, sources, relation_types) {
  data = json.recommendations;

  // remove duplicate events based on id
  data = _.uniq(data, "id");

  json.href = "?page={{number}}";
  if (relation_type_id !== "") { json.href += "&relation_type_id=" + relation_type_id; }
  if (source_id !== "") { json.href += "&source_id=" + source_id; }

  d3.select("#loading-recommendations").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content-recommendations").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no recommendations");
    return;
  }

  d3.select("#content-recommendations").insert("div")
    .attr("id", "results-recommendations");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var date_parts = work["issued"]["date-parts"][0];
    var date = datePartsToDate(date_parts);
    var relation = relationToString(work, sources, relation_types);

    d3.select("#results-recommendations").append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.id); })
      .html(work.title);
    d3.select("#results-recommendations").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results-recommendations").append("a")
      .attr("href", function() { return work.id; })
      .text(work.id);
    d3.select("#results").append("p")
      .text(signpostsToString(work, sources, source_id, sort));
  }
}
