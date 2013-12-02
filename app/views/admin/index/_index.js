var data;
var api_key = d3.select("h1#api_key").attr('data-api_key');

d3.json("/api/v3/status?api_key=" + api_key, function(error, json) {
  data = json;

  var formatFixed = d3.format(",.0f");

  for (var item in data) {
    if(item.substr(item.length - 5) == "count") {
      d3.select("#" + item).html(number_with_delimiter(data[item]));
    } else if(item.substr(item.length - 4) == "size") {
      d3.select("#" + item).html(number_to_human_size(data[item]));
    } else {
      d3.select("#" + item).html(data[item]);
    }
  };

  function number_with_delimiter(number) { return formatFixed(number); }

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