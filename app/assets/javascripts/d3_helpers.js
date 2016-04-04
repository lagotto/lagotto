/*global d3 */

var formatDate = d3.time.format.utc("%B %d, %Y"),
    formatMonthYear = d3.time.format.utc("%B %Y"),
    formatYear = d3.time.format.utc("%Y"),
    formatTime = d3.time.format.utc("%H:%M UTC"),
    formatWeek = d3.time.format.utc("%U"),
    formatHour = d3.time.format.utc("%H"),
    formatNumber = d3.format(",d"),
    formatFixed = d3.format(",.0f"),
    formatPercent = d3.format(",.0%");

function numberWithDelimiter(number) {
  if(number !== 0) {
    return formatFixed(number);
  } else {
    return null;
  }
}

// Format file size into human-readable format
function numberToHumanSize(bytes) {
  var thresh = 1000;
  if(bytes < thresh) { return bytes + ' B'; }
  var units = ['KB','MB','GB','TB','PB'];
  var u = -1;
  do { bytes /= thresh; ++u; } while(bytes >= thresh);
  return bytes.toFixed(1) + ' ' + units[u];
}

// format date
function formattedDate(date) {
  var timestamp = new Date(Date.parse(date));
  switch (date.length) {
    case 4:
      return formatYear(timestamp);
    case 7:
      return formatMonthYear(timestamp);
    default:
      return formatDate(timestamp);
  }
}

// pagination
function paginate(json, tag) {
  if ((json.meta.page !== "") && json.meta.total_pages > 1) {
    var prev = (json.meta.page > 1) ? "«" : null;
    var next = (json.meta.page < json.meta.total_pages) ? "»" : null;

    d3.select(tag).append("div")
      .attr("id", "paginator")
      .attr("class", "text-center");

    $('#paginator').bootpag({
      total: json.meta.total_pages,
      page: json.meta.page,
      maxVisible: 10,
      href: json.href,
      leaps: false,
      prev: prev,
      next: next
    });
  }
}

// link to individual work
function pathForWork(id) {
  if (typeof id === "undefined") { return ""; };

  if (id.substring(0, 15) === "http://doi.org/" ||
      id.substring(0, 35) === "http://www.ncbi.nlm.nih.gov/pubmed/" ||
      id.substring(0, 41) === "http://www.ncbi.nlm.nih.gov/pmc/works/PMC" ||
      id.substring(0, 41) === "http://www.ncbi.nlm.nih.gov/pmc/works/PMC" ||
      id.substring(0, 21) === "http://arxiv.org/abs/" ||
      id.substring(0, 15) === "http://n2t.net/") {
    return id.replace(/^https?:\/\//,'');
  } else {
    return id;
  }
}

function signpostsToString(work, sources, source_id, sort) {
  var name = "";
  if (typeof source_id !== "undefined" && source_id !== "") {
    name = source_id;
  } else if (typeof sort !== "undefined" && sort !== "") {
    name = sort;
  }

  if (name !== "") {
    var source = sources.filter(function(d) { return d.id === name; })[0];
  }

  if (typeof source !== "undefined" && source !== "") {
    var a = [source.title + ": " + formatFixed(work.events[name])];
  } else {
    var a = [];
  }

  var b = [],
      signposts = signpostsFromWork(work);

  if (signposts.viewed > 0) { b.push("Viewed: " + formatFixed(signposts.viewed)); }
  if (signposts.cited > 0) { b.push("Cited: " + formatFixed(signposts.cited)); }
  if (signposts.saved > 0) { b.push("Saved: " + formatFixed(signposts.saved)); }
  if (signposts.discussed > 0) { b.push("Discussed: " + formatFixed(signposts.discussed)); }
  if (b.length > 0) {
    a.push(b.join(" • "));
    return a.join(" | ");
  } else if (a.length > 0) {
    return a;
  } else {
    return "";
  }
}

function signpostsFromWork(work) {
  var viewed = (work.events.counter || 0) + (work.events.pmc || 0);
  var cited = work.events.crossref;
  var saved = (work.events.citeulike || 0) + (work.events.mendeley || 0);
  var discussed = (work.events.facebook || 0) + (work.events.twitter || 0) + (work.events.twitter_search || 0);

  return { "viewed": viewed, "cited": cited, "saved": saved, "discussed": discussed };
}

function relationToString(work, sources, relation_types) {
  var source = sources.filter(function(d) { return d.id === work.source_id; })[0];
  if (typeof source == "undefined" || source === "") { source = {}; }

  var relation_type = relation_types.filter(function(d) { return d.id === work.relation_type_id; })[0];
  if (typeof relation_type == "undefined" || relation_type === "") { relation_type = {}; }

  return [relation_type.title, " via " + source.title];
}

function metadataToString(work, work_types) {;
  var containerTitleString = work["container-title"] ? " via " + work["container-title"] : "";

  var work_type = work_types.filter(function(d) { return d.id === work.work_type_id; })[0];
  if (typeof work_type == "undefined" || work_type === "") { work_type = { "title": "Work" }; }

  return work_type.title + " published " + formattedDate(work.issued) + containerTitleString;
}

// construct author list from author object
function formattedAuthorList(authorList) {
  authorList = authorList.map(function(d) { return formattedAuthor(d); });
  switch (authorList.length) {
    case 0:
    case 1:
    case 2:
      return authorList.join(" & ");
    case 3:
    case 4:
      return authorList.slice(0,-1).join(", ") + " & " + authorList[authorList.length - 1];
    default:
      return authorList.slice(0,3).join(", ") + ", <em>et al</em>";
  }
}

// construct author object from author parts
function formattedAuthor(author) {
  var given = (typeof author.given !== "undefined") ? author.given : "";
  var family = (typeof author.family !== "undefined") ? author.family : "";
  var name = [given, family].join(" ");
  var name = (typeof author["ORCID"] !== "undefined") ? '<a href="/contributors/' + author["ORCID"].substring(7) + '">' + name + '</a>' : name;
  return name;
}
