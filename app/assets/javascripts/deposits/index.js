/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var api_key = params.attr('data-api-key');
  var page = params.attr('data-page');
  if (page == null) { page = 1; }
  var per_page = params.attr('data-per-page');
  var q = params.attr('data-q');
  var source_id = params.attr('data-source-id');
  var state = params.attr('data-state');

  var query = encodeURI("/api/deposits?page=" + page);
  if (per_page !== null) { query += "&per_page=" + per_page; }
  query += "&from_date=" + formattedPastDate(7);
  if (q !== null) { query += "&q=" + q; }
  if (source_id !== null) { query += "&source_id=" + source_id; }
  if (state !== null) { query += "&state=" + state; }
}

// asynchronously load data from the Lagotto API
queue()
  .defer(d3.json, encodeURI("/api/sources"))
  .defer(d3.json, encodeURI("/api/relation_types"))
  .defer(d3.json, query)
  .await(function(error, s, r, d) {
    if (error) { return console.warn(error); }
    eventsViz(d, s.sources, r.relation_types);
    paginate(d, "#content");
});

// add data to page
function eventsViz(json, sources, relation_types) {
  data = json.deposits;

  json.href = "?page={{number}}";
  if (q !== null) { json.href += "&q=" + q; }
  if (state !== null) { json.href += "&state=" + state; }
  if (source_id !== null) { json.href += "&source_id=" + source_id; }

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no deposits");
    return;
  }

  if (json.meta.total > 1) {
    d3.select("#content").insert("h4")
      .attr("class", "results")
      .text(numberWithDelimiter(json.meta.total) + " Deposits");
  }

  for (var i=0; i<data.length; i++) {
    var deposit = data[i];
    var source = sources.filter(function(d) { return d.id === deposit.source_id; })[0];
    var relation_type = relation_types.filter(function(d) { return d.id === deposit.relation_type_id; })[0];

    d3.select("#content").insert("div")
      .attr("class", "panel panel-default")
      .attr("id", "panel-" + i).insert("div")
      .attr("class", "panel-heading panel-title panel-list")
      .html(deposit.id).append("small")
      .attr("class", "pull-right")
      .html(formattedState(deposit.state));

      d3.select("#panel-" + i).insert("div")
        .attr("class", "panel-body deposit")
        .attr("id", "panel-body-" + i);

    if (typeof deposit.obj_id !== "undefined") {
      d3.select("#panel-body-" + i).append("div")
        .text(relation_type.title + " ").append("a")
        .attr("href", function() { return pathForWork(deposit.obj_id); })
        .html(deposit.obj_id);
    }

    d3.select("#panel-body-" + i).append("div")
      .text("Updated at " + formattedDate(deposit.timestamp));

    // for (var key in deposit.subj) {
    //   d3.select("#panel-body-" + i).append("h5")
    //     .text(key);
    //   d3.select("#panel-body-" + i).append("div")
    //     .html(function() { return deposit.subj[key]; });
    // }

    if (typeof deposit.errors !== "undefined") {
      var error_key = Object.keys(deposit.errors);

      d3.select("#panel-body-" + i).append("h5")
        .text("Errors in " + error_key);
      d3.select("#panel-body-" + i).append("div")
        .html(deposit.errors[error_key]);
    }

    if (deposit.message_type === "publisher") {
      d3.select("#panel-" + i).insert("div")
        .attr("class", "panel-footer")
        .attr("id", "panel-footer-" + i).append("span")
        .html('<i class="fa fa-info-circle"/>').append("span")
        .text(deposit.subj_id);
    } else {
      d3.select("#panel-" + i).insert("div")
        .attr("class", "panel-footer")
        .attr("id", "panel-footer-" + i).append("a")
        .attr("href", function() { return deposit.subj_id; })
        .html('<i class="fa fa-external-link"/>').append('span')
        .text(deposit.subj_id);
    }

    if (typeof source !== "undefined") {
      d3.select("#panel-footer-" + i).append("a")
        .attr("class", "pull-right")
        .attr("href", function() { return "/deposits?source_id=" + deposit.source_id; })
        .text(source.title);
    }
  }
}
