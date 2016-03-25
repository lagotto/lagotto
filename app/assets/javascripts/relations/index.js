/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page == null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var q = params.attr('data-q');
  var source_id = params.attr('data-source-id');
  var relation_type_id = params.attr('data-relation-type-id');

  var query = encodeURI("/api/relations?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (q !== null) { query += "&q=" + q; }
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
    eventsViz(w, s.sources, r.relation_types);
    paginate(w, "#content");
});

// add data to page
function eventsViz(json, sources, relation_types) {
  data = json.relations;

  json.href = "?page={{number}}";
  if (q !== null) { json.href += "&q=" + q; }
  if (relation_type_id !== null) { json.href += "&relation_type_id=" + relation_type_id; }
  if (source_id !== null) { json.href += "&source_id=" + source_id; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no relations");
    return;
  }

  if (json.meta.total > 1) {
    d3.select("#content").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(json.meta.total) + " Relations");

    d3.select("#relation-sort").classed("hidden", false);
  }

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var relation_type = relation_types.filter(function(d) { return d.id === work.relation_type_id; })[0];
    var source = sources.filter(function(d) { return d.id === work.source_id; })[0];

    d3.select("#content").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-" + i).insert("div")
      .attr("class", "panel-body")
      .attr("id", "panel-body-" + i);

    d3.select("#panel-body-" + i).append("h4")
      .attr("class", "work").append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.subj_id); })
      .html(work.title);
    d3.select("#panel-body-" + i).append("p")
      .html(formattedAuthor(work.author)).append("p")
      .html(metadataToString(work)).append("p")
      .append("span")
      .text(relation_type.title + " ").append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.obj_id); })
      .html(work.obj_id);
    d3.select("#panel-body-" + i).append("p")
      .text(signpostsToString(work, sources));

    d3.select("#panel-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-footer-" + i).append("a")
      .attr("href", function() { return work.subj_id; })
      .html(work.subj_id);
    d3.select("#panel-footer-" + i).append("a")
      .attr("class", "pull-right")
      .attr("href", function() { return "/relations?source_id=" + work.source_id; })
      .text(source.title);
  }
}
