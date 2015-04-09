/*global d3 */

var params = d3.select("#api_key");

if (!params.empty()) {
  var reference_id = params.attr('data-pid');
  var query = encodeURI("/api/works/" + reference_id + "/references");
}

// load the data from the Lagotto API
if (query) {
  d3.json(query)
    .header("Accept", "application/vnd.lagotto+json; version=6")
    .get(function(error, json) {
      if (error) { return console.warn(error); }
      referencesViz(json);
  });
}

// add data to page
function referencesViz(json) {
  data = json.references;

  d3.select("#loading-results").remove();

  if (typeof data === "undefined" || data.length === 0) {
    d3.select("#content-references").text("")
      .insert("div")
      .attr("class", "alert alert-info")
      .text("There are currently no references");
    return;
  }

  d3.select("#content-references").insert("div")
    .attr("id", "results");

  for (var i=0; i<data.length; i++) {
    var work = data[i];
    var date_parts = work["issued"]["date-parts"][0];
    var date = datePartsToDate(date_parts);

    d3.select("#results").append("h4")
      .attr("class", "work")
      .append("a")
      .attr("href", function() { return "/works/" + work.id; })
      .html(work.title);
    d3.select("#results").append("span")
      .attr("class", "date")
      .text(formattedDate(date, date_parts.length) + ". ");
    d3.select("#results").append("a")
      .attr("href", function() { return urlForWork(work); })
      .text(urlForWork(work));
    d3.select("#results").append("p")
      .text(signpostsToString(work));
  }
}
