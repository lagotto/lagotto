var data;
var colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"];

var l = 200; // left margin
var r = 150; // right margin
var w = 600; // width of drawing area
var h = 36;  // bar height
var s = 2;   // spacing between bars

// construct query string
var params = d3.select("h1#api_key");
if (params.empty()) throw "Missing id #api_key";

var api_key = params.attr('data-api_key');
var query = encodeURI("/api/v5/sources?api_key=" + api_key);

// load the data from the ALM API
d3.json(query, function(error, json) {
    if (error) return console.warn(error);
    data = json["data"];
    jobsViz(data);
    articlesViz(data);
    eventsViz(data);
});

// add data to page
function jobsViz(data) {
    for (var i=0; i<data.length; i++) {
        item = data[i];

        // Jobs tab
        d3.select("#queued_count_" + item["name"]).html(numberWithDelimiter(item["status"]["queued"]));
        d3.select("#stale_count_" + item["name"]).html(numberWithDelimiter(item["status"]["stale"]));

        // Responses tab
        d3.select("#response_count_" + item["name"]).html(numberWithDelimiter(item["responses"]["count"]));
        d3.select("#average_count_" + item["name"]).html(numberWithDelimiter(item["responses"]["average"]));
        if(item["error_count"] > 0) {
          d3.select("#error_count_" + item["name"]).html("<a href='/admin/alerts?source=" + item["name"] + "'>" + formatFixed(item["error_count"]) + "</a>");
        }
    };
}

// articles bar chart
function articlesViz(data) {

    // remove source not needed for the following visualizations
    data = data.filter(function(d) { return d.name != "relativemetric"; });

    // Articles tab
    var chart = d3.select("div#articles").append("svg")
        .attr("width", w + l + r)
        .attr("height", data.length * (h + 2 * s) + 30)
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(250,20)");

    var x = d3.scale.linear()
        .domain([0, d3.max(data, function(d) { return d.article_count; })])
        .range([0, w]);
    var y = d3.scale.ordinal()
        .domain(data.map(function(d) { return d.display_name; }))
        .rangeBands([0, (h + 2 * s) * data.length]);
    var z = d3.scale.ordinal()
        .domain(data.map(function(d) { return d.group; }))
        .range(colors);

    chart.selectAll("text.labels")
        .data(data)
        .enter().append("a").attr("xlink:href", function(d) { return "/admin/sources/" + d.name; }).append("text")
        .attr("x", 0)
        .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
        .attr("dx", -250) // padding-right
        .attr("dy", ".35em") // vertical-align: middle
        .text(function(d) { return d.display_name; });
    chart.selectAll("rect")
        .data(data)
        .enter().append("rect")
        .attr("fill", function(d) { return z(d.group); })
        .attr("y", function(d,i) { return y(d.display_name); })
        .attr("height", h)
        .attr("width", function(d) { return x(d.article_count); });
    chart.selectAll("text.values")
        .data(data)
        .enter().append("text")
        .attr("x", function(d) { return x(d.article_count); })
        .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
        .attr("dx", 5) // padding-right
        .attr("dy", ".35em") // vertical-align: middle
        .text(function(d) { return numberWithDelimiter(d.article_count); });
}

// events bar chart
function eventsViz(data) {

    // remove source not needed for the following visualizations
    data = data.filter(function(d) { return d.name != "relativemetric"; });

    // Events tab
    var chart = d3.select("div#events").append("svg")
        .attr("width", w + l + r)
        .attr("height", data.length * (h + 2 * s) + 30)
        .attr("class", "chart")
        .append("g")
        .attr("transform", "translate(250,20)");

    var x = d3.scale.log()
        .domain([0.1, d3.max(data, function(d) { return d.event_count; })])
        .range([1, w]);
    var y = d3.scale.ordinal()
        .domain(data.map(function(d) { return d.display_name; }))
        .rangeBands([0, (h + 2 * s) * data.length]);
    var z = d3.scale.ordinal()
        .domain(data.map(function(d) { return d.group; }))
        .range(colors);

    chart.selectAll("text.labels")
        .data(data)
        .enter().append("a").attr("xlink:href", function(d) { return "/admin/sources/" + d.name; }).append("text")
        .attr("x", 0)
        .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
        .attr("dx", -250) // padding-right
        .attr("dy", ".35em") // vertical-align: middle
        .text(function(d) { return d.display_name; });
    chart.selectAll("rect")
        .data(data)
        .enter().append("rect")
        .attr("fill", function(d) { return z(d.group); })
        .attr("y", function(d) { return y(d.display_name); })
        .attr("height", h)
        .attr("width", function(d) { return x(d.event_count); });
    chart.selectAll("text.values")
        .data(data)
        .enter().append("text")
        .attr("x", function(d) { return x(d.event_count); })
        .attr("y", function(d) { return y(d.display_name) + y.rangeBand() / 2; })
        .attr("dx", 5) // padding-right
        .attr("dy", ".35em") // vertical-align: middle
        .text(function(d) { return numberWithDelimiter(d.event_count); });
}

// d3 helper functions
var formatFixed = d3.format(",.0f");

function numberWithDelimiter(number) {
    if(number !== 0) {
        return formatFixed(number);
    } else {
        return null;
    }
}
