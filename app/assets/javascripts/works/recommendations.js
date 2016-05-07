/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var work_id = params.attr('data-pid');
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var source_id = params.attr('data-source-id');
  var relation_type_id = params.attr('data-relation-type-id');

  var query = encodeURI("/api/works/" + pathForWork(work_id) + "/recommendations?page=" + page);
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (relation_type_id !== null) { query += "&relation_type_id=" + relation_type_id; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/relation_types"))
  .defer(d3.json, encodeURI("/api/work_types"))
  .defer(d3.json, query)
  .await(function(error, s, r, wt, w) {
    if (error) { return console.warn(error); }
    recommendationsViz(w, s.sources, r.relation_types, wt.work_types);
});

// add data to page
function recommendationsViz(json, sources, relation_types, work_types) {
  data = json.recommendations;

  // remove duplicate events based on id
  data = _.uniq(data, "id");

  json.href = "?page={{number}}";
  if (relation_type_id !== null) { json.href += "&relation_type_id=" + relation_type_id; }
  if (source_id !== null) { json.href += "&source_id=" + source_id; }

  d3.select("#loading-recommendations").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content-recommendations").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no recommendations");
    return;
  }

  if (data.length > 1) {
    d3.select("#content-recommendations").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(data.length) + " Recommendations");
  }

  d3.select("#content-recommendations").insert("div")
    .attr("id", "results-recommendations");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var relation_type = relation_types.filter(function(d) { return d.id === work.relation_type_id; })[0];
    var source = sources.filter(function(d) { return d.id === work.source_id; })[0];

    d3.select("#content-recommendations").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-recommendations-" + i).insert("div")
      .attr("class", "panel-body")
      .attr("id", "panel-body-recommendations-" + i);

    d3.select("#panel-body-recommendations-" + i).append("h4")
      .attr("class", "work").append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.subj_id); })
      .html(work.title);

    d3.select("#panel-body-recommendations-" + i).append("div")
      .attr("class", "author")
      .html(formattedAuthorList(work.author));
    d3.select("#panel-body-recommendations-" + i).append("div")
      .attr("class", "metadata")
      .html(metadataToString(work, work_types));

    d3.select("#panel-recommendations-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-recommendation-" + i).append("span")
      .text(relation_type.title + " ").append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.obj_id); })
      .text(work.obj_id);
    d3.select("#panel-recommendation-" + i).append("a")
      .attr("class", "pull-right")
      .attr("href", function() { return "/relations?source_id=" + work.source_id; })
      .text(source.title);

    var signposts = signpostsFromWork(work, sources);
    if (typeof signposts !== "undefined" && signposts.length > 0)  {
      for (var j=0; j<signposts.length; j++) {
        d3.select("#panel-" + i).insert("div")
          .attr("class", "panel-footer")
          .attr("id", "panel-signpost-" + i + j).append("a")
          .attr("href", function() { return "/works/" + pathForWork(work.obj_id); })
          .text(formatFixed(signposts[j].count));
        d3.select("#panel-signpost-" + i + j).append("a")
          .attr("class", "pull-right")
          .attr("href", function() { return "/works?source_id=" + signposts[j].name; })
          .text(signposts[j].title);
      }
    }

    d3.select("#panel-recommendations-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-footer-recommendations-" + i).append("a")
      .attr("href", function() { return work.subj_id; })
      .html('<i class="fa fa-external-link"/>').append('span')
      .text(work.subj_id);
    d3.select("#panel-footer-recommendations-" + i).append("a")
      .attr("class", "pull-right")
      .attr("href", function() { return "/relations?source_id=" + work.source_id; })
      .text(source.title);
  }
}
