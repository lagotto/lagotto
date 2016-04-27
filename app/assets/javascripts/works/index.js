/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page === null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var q = params.attr('data-q');
  var publisher_id = params.attr('data-publisher-id');
  var contributor_id = params.attr('data-contributor-id');
  var source_id = params.attr('data-source-id');
  var relation_type_id = params.attr('data-relation-type-id');
  var registration_agency_id = params.attr('data-registration-agency-id');
  var sort = params.attr('data-sort');
  var model = params.attr('data-model');

  var query = encodeURI("/api/works?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  if (q !== null) { query += "&q=" + q; }
  if (publisher_id !== null) { query += "&publisher_id=" + publisher_id; }
  if (registration_agency_id !== null) { query += "&registration_agency_id=" + registration_agency_id; }
  if (contributor_id !== null) { query += "&contributor_id=" + contributor_id; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (relation_type_id !== null) { query += "&relation_type_id=" + relation_type_id; }
  if (sort !== null) { query += "&sort=" + sort; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/work_types"))
  .defer(d3.json, encodeURI("/api/registration_agencies"))
  .defer(d3.json, query)
  .await(function(error, s, wt, r, w) {
    if (error) { return console.warn(error); }
    worksViz(w, s.sources, wt.work_types, r.registration_agencies);
    if (model !== "sources") { paginate(w, "#content"); }
});

// add data to page
function worksViz(json, sources, work_types, registration_agencies) {
  data = json.works;

  json.href = "?page={{number}}";
  if (q !== null) { json.href += "&q=" + q; }
  if (publisher_id !== null && model !== "publishers") { json.href += "&publisher_id=" + publisher_id; }
  if (contributor_id !== null && model !== "contributors") { json.href += "&contributor_id=" + contributor_id; }
  if (registration_agency_id !== null) { json.href += "&registration_agency_id=" + registration_agency_id; }
  if (source_id !== null) { json.href += "&source_id=" + source_id; }
  if (relation_type_id !== null) { json.href += "&relation_type_id=" + relation_type_id; }
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

  if (json.meta.total > 1 && model !== "sources") {
    d3.select("#content").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(json.meta.total) + " Works");

    d3.select("#work-sort").classed("hidden", false);
  }

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var registration_agency = registration_agencies.filter(function(d) { return d.id === work.registration_agency_id; })[0];

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
    d3.select("#panel-body-" + i).append("div")
      .attr("class", "author")
      .html(formattedAuthorList(work.author));
    d3.select("#panel-body-" + i).append("div")
      .attr("class", "metadata")
      .html(metadataToString(work, work_types));

    var signposts = signpostsFromWork(work, sources, source_id, sort);
    if (typeof signposts !== "undefined" && signposts.length > 0)  {
      for (var j=0; j<signposts.length; j++) {
        d3.select("#panel-" + i).insert("div")
          .attr("class", "panel-footer")
          .attr("id", "panel-signpost-" + i + j).append("a")
          .attr("href", function() { return "/works?source_id=" + signposts[j].name; })
          .text(signposts[j].title);
        if (signposts[j].count > 1) {
          d3.select("#panel-signpost-" + i + j).append("span")
            .attr("class", "badge")
            .html(formatFixed(signposts[j].count));
        }
      }
    }

    d3.select("#panel-" + i).insert("div")
      .attr("class", "panel-footer")
      .attr("id", "panel-footer-" + i).append("a")
      .attr("href", function() { return work.id; })
      .html('<i class="fa fa-external-link"/>').append('span')
      .text(work.id);

    if (typeof registration_agency !== "undefined") {
      d3.select("#panel-footer-" + i).append("a")
        .attr("class", "pull-right")
        .text(registration_agency.title);
      }
    }
}
