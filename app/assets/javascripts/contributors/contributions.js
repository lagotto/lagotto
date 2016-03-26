/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var contributor_id = params.attr('data-contributor-id');
  var source_id = params.attr('data-source-id');
  var sort = params.attr('data-sort');

  var query = encodeURI("/api/contributors/" + contributor_id + "/contributions?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (sort !== null) { query += "&sort=" + sort; }
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
      .text("There are currently no contributions");
    return;
  }

  if (json.meta.total > 1) {
    d3.select("#content").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(json.meta.total) + " Contributions");
  }

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var source = sources.filter(function(d) { return d.id === work.source_id; })[0];

    d3.select("#content").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-" + i).insert("div")
      .attr("class", "panel-body")
      .attr("id", "panel-body-" + i);

    d3.select("#panel-body-" + i).append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + pathForWork(work.obj_id); })
      .html(work.title);
    d3.select("#panel-body-" + i).append("p")
      .html(formattedAuthorList(work.author)).append("p")
      .html(metadataToString(work));
    d3.select("#panel-body" + i).append("p")
      .text(signpostsToString(work, sources, source_id, sort));

    d3.select("#panel-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-footer-" + i).append("a")
      .attr("href", function() { return work.obj_id; })
      .html('<i class="fa fa-external-link"/>').append('span')
      .text(work.obj_id);
    d3.select("#panel-footer-" + i).append("a")
      .attr("class", "pull-right")
      .attr("href", function() { return "/contributors/" + pathForWork(work.subj_id) + "?source_id=" + work.source_id; })
      .text(source.title);
  }
}
