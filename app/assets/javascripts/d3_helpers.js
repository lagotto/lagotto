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

// construct date object from date parts
function datePartsToDate(date_parts) {
  var len = date_parts.length;

  // not in expected format
  if (len === 0 || len > 3) { return null; }

  // turn numbers to strings and pad with 0
  for (var i = 0; i < len; ++i) {
    if (date_parts[i] < 10) {
      date_parts[i] = "0" + date_parts[i];
    } else {
      date_parts[i] = "" + date_parts[i];
    }
  }

  // convert to date, workaround for different time zones
  var timestamp = Date.parse(date_parts.join('-') + 'T12:00');
  return new Date(timestamp);
}

// format date
function formattedDate(date, len) {
  switch (len) {
    case 1:
      return formatYear(date);
    case 2:
      return formatMonthYear(date);
    case 3:
      return formatDate(date);
  }
}

// pagination for events
function paginateEvents(data, page) {
  if (data.length > 50) {
    var total = Math.ceil(data.length/50);
    var max_visible = 10;
    var href = "#events?page={{number}}";
    var prev = (page > 1) ? "«" : null;
    var next = (page < total) ? "»" : null;

    d3.select("#results").append("div")
      .attr("id", "paginator");

    $('#paginator').bootpag({
      total: total,
      page: page,
      maxVisible: max_visible,
      href: href,
      leaps: false,
      prev: prev,
      next: next
    }).on("page", function(event, num) {
      showEvents(data, num);
    });
  }
}
// pagination
function paginate(json) {
  if ((page !== "") && json.total_pages > 1) {
    var prev = (json.page > 1) ? "«" : null;
    var next = (json.page < json.total_pages) ? "»" : null;

    d3.select("#content").append("div")
      .attr("id", "paginator")
      .attr("class", "text-center");

    $('#paginator').bootpag({
      total: json.total_pages,
      page: json.page,
      maxVisible: 10,
      href: json.href,
      leaps: false,
      prev: prev,
      next: next
    });
  }
}

// link to individual work
function urlForWork(work) {
  if (!!work.doi) {
    return "http://dx.doi.org/" + work.doi;
  } else if (!!work.pmid) {
    return "http://www.ncbi.nlm.nih.gov/pubmed/" + work.pmid;
  } else if (!!work.pmcid) {
    return "http://www.ncbi.nlm.nih.gov/pmc/works/PMC" + work.pmcid;
  } else if (!!work.ark) {
    return "http://n2t.net/" + work.ark;
  } else if (!!work.canonical_url) {
    return work.canonical_url;
  } else {
    return "";
  }
}

function signpostsToString(work, source_id, order) {
  if (source_id === "" && order === "") {
    var a = [];
  } else {
    if (order !== "") { var name = order }
    if (source_id !== "") { var name = source_id }
    var s = work.sources.filter(function(d) { return d.name === name; })[0];
    var a = [s.title + ": " + formatFixed(s.total)];
  }

  var b = [];
  if (work.viewed > 0) { b.push("Viewed: " + formatFixed(work.viewed)); }
  if (work.cited > 0) { b.push("Cited: " + formatFixed(work.cited)); }
  if (work.saved > 0) { b.push("Saved: " + formatFixed(work.saved)); }
  if (work.discussed > 0) { b.push("Discussed: " + formatFixed(work.discussed)); }
  if (b.length > 0) {
    a.push(b.join(" • "));
    return a.join(" | ");
  } else if (a.length > 0) {
    return a;
  } else {
    return "";
  }
}

// construct author object from author parts
function formattedAuthor(author) {
  author = author.map(function(d) { return d.given + " " + d.family; });
  switch (author.length) {
    case 0:
    case 1:
    case 2:
      return author.join(" & ");
    case 3:
    case 4:
      return author.slice(0,-1).join(", ") + " & " + author[author.length - 1];
    default:
      return author.slice(0,3).join(", ") + ", <em>et al</em>";
  }
}

// format event type
function formattedType(type) {
  var types = { "article-journal": "Journal article",
                "article-newspaper": "News",
                "post": "Blog post",
                "webpage": "Web page",
                "broadcast": "Podcast/Video",
                "personal_communication": "Personal communication" };
  return types[type] || "Other";
}
