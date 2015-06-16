/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var work_id = params.attr('data-pid');
  var api_key = params.attr('data-api_key');
  var page = params.attr('data-page');
  if (page === "") { page = 1; }
  var per_page = params.attr('data-per_page');
  var source_id = params.attr('data-source_id');
  var relation_type_id = params.attr('data-relation_type_id');

  var query = encodeURI("/api/works/" + work_id + "/references?page=" + page);
  if (per_page !== "") { query += "&per_page=" + per_page; }
  if (source_id !== "") { query += "&source_id=" + source_id; }
  if (relation_type_id !== "") { query += "&relation_type_id=" + relation_type_id; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/relation_types"))
  .defer(d3.json, query)
  .await(function(error, s, r, w) {
    if (error) { return console.warn(error); }
    eventsViz(w, s.sources, r.relation_types);
    paginate(w);
});

// add data to page
function eventsViz(json, sources, relation_types) {
  data = json.references;

  // remove duplicate events based on id
  data = _.uniq(data, "id");

  json.href = "?page={{number}}";
  if (relation_type_id !== "") { json.href += "&relation_type_id=" + relation_type_id; }
  if (source_id !== "") { json.href += "&source_id=" + source_id; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no references");
    return;
  }

  d3.select("#content").insert("div")
    .attr("id", "results");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var date_parts = work["issued"]["date-parts"][0];
    var date = datePartsToDate(date_parts);
    var relation = relationToString(work, sources, relation_types);

    d3.select("#results").append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + pathForWork(work); })
      .html(work.title);
    d3.select("#results").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results").append("a")
      .attr("href", function() { return work.id; })
      .text(work.id);
    d3.select("#results").append("p")
      .text(signpostsToString(work, sources));
    d3.select("#results").append("span")
      .text(relation[0] + " ")
      .append("a")
      .attr("href", function() { return "/works/" + work.work_id; })
      .html(work.work_id);
    d3.select("#results").append("span")
      .text(relation[1]);
  }

  d3.select("div#rss").style("display", "inline");
}
