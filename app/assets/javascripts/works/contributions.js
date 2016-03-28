/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var work_id = params.attr('data-pid');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var source_id = params.attr('data-source-id');
  var contributor_role_id = params.attr('data-contributor-role-id');

  var query = encodeURI("/api/works/" + work_id + "/contributions?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (contributor_role_id !== null) { query += "&contributor_role_id=" + contributor_role_id; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/contributor_roles"))
  .defer(d3.json, query)
  .await(function(error, s, cr, c) {
    if (error) { return console.warn(error); }
    contributionsViz(c, s.sources, cr.contributor_roles);
    paginate(c, "#content-contributions");
});

// add data to page
function contributionsViz(json, sources, contributor_roles) {
  data = json.contributions;

  json.href = "?page={{number}}";
  if (source_id !== "") { json.href += "&source_id=" + source_id; }
  if (sort !== "") { json.href += "&sort=" + sort; }

  d3.select("#loading-contributions").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no contributions");
    return;
  }

  if (json.meta.total > 1) {
    d3.select("#content-contributions").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(json.meta.total) + " Contributions");
  }

  for (var i=0; i<data.length; i++) {
    var contribution = data[i];
    var contributor_role = contributor_roles.filter(function(d) { return d.id === contribution.contributor_role_id; })[0];
    if (typeof contributor_role === "undefined") { contributor_role = { "title": "Contribution" }};
    var source = sources.filter(function(d) { return d.id === contribution.source_id; })[0];
    var author = [contribution.given, contribution.family].join(" ");

    d3.select("#content-contributions").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-contribution-" + i).insert("div")
      .attr("class", "panel-body")
      .attr("id", "panel-body-contribution-" + i);

    d3.select("#panel-body-contribution-" + i).append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/contributors/" + pathForWork(contribution.subj_id); })
      .html(function() { return formattedAuthorList(author); });
    d3.select("#panel-body-contribution-" + i).append("p")
      .append("span")
      .text(contributor_role.title);
    d3.select("#panel-body" + i).append("p")
      .text(signpostsToString(contribution, sources, source_id, sort));

    d3.select("#panel-contribution-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-footer-contribution-" + i).append("a")
      .attr("href", function() { return contribution.subj_id; })
      .html('<i class="fa fa-external-link"/>').append('span')
      .text(contribution.subj_id);
    d3.select("#panel-footer-contribution-" + i).append("a")
      .attr("class", "pull-right")
      .attr("href", function() { return "/works/" + pathForWork(contribution.obj_id) + "?source_id=" + contribution.source_id; })
      .text(source.title);
  }
}
