// construct query string
var params = d3.select("h1#api_key");
if (!params.empty()) {
  var api_key = params.attr('data-api_key');
  var query = encodeURI("/api/v5/status?api_key=" + api_key);
}

// load the data from the ALM API
if (query) {
  d3.json(query, function(error, json) {
    if (error) return console.warn(error);
    data = json['data'];
    statusViz(data);
  });
}

// add data to page
function statusViz(data) {
  for (var item in data) {
    if(item.substr(item.length - 5) == "count") {
      d3.select("#" + item).html(formatFixed(data[item]));
    } else if(item.substr(item.length - 4) == "size") {
      d3.select("#" + item).html(numberToHumanSize(data[item]));
    } else if(item == "update_date") {
      d3.select("#" + item).html(formatTime(inputTime.parse(data[item])));
    } else {
      d3.select("#" + item).html(data[item]);
    }
  };
}

// d3 helper functions
var formatFixed = d3.format(",.0f");
var inputTime = d3.time.format.iso;
var formatTime = d3.time.format.utc("%d %b %H:%M UTC");

// Format file size into human-readable format
function numberToHumanSize(bytes) {
  var thresh = 1000;
  if (bytes < thresh) return bytes + ' B';
  var units = ['kB','MB','GB','TB','PB'];
  var u = -1;
  do {
    bytes /= thresh;
    ++u;
  } while (bytes >= thresh);
  return bytes.toFixed(1)+' '+units[u];
};
