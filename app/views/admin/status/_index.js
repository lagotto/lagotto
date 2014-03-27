var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');

d3.json("/api/v5/status?api_key=" + api_key, function(error, json) {
  data = json["data"];

  var formatFixed = d3.format(",.0f");
  var inputTime = d3.time.format.iso;
  var formatTime = d3.time.format.utc("%d %b %H:%M UTC");

  for (var item in data) {
    if(item.substr(item.length - 5) == "count") {
      d3.select("#" + item).html(formatFixed(data[item]));
    } else if(item.substr(item.length - 4) == "size") {
      d3.select("#" + item).html(number_to_human_size(data[item]));
    } else if(item == "update_date") {
      d3.select("#" + item).html(formatTime(inputTime.parse(data[item])));
    } else {
      d3.select("#" + item).html(data[item]);
    }
  };

  // Format file size into human-readable format
  function number_to_human_size(bytes) {
    var thresh = 1000;
    if(bytes < thresh) return bytes + ' B';
    var units = ['kB','MB','GB','TB','PB'];
    var u = -1;
    do {
        bytes /= thresh;
        ++u;
    } while(bytes >= thresh);
    return bytes.toFixed(1)+' '+units[u];
  };
});