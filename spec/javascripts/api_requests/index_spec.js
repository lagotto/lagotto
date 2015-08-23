//= require api_requests/index

describe("api_requests index", function() {

  var json = {"meta":{"status":"ok","message-type":"api_request-list","message-version":"6.0.0","total":439110,"total_pages":440,"page":1},"api_requests":[{"id":"c1819de1-1479-442f-b5fe-f034e3081ebb","api_key":"3pezRBRXdyzYW6ztfwft","info":"detail","ids":"10.1371/journal.pmed.1001388","db_duration":15.6879,"view_duration":48.1693,"duration":63.8573,"timestamp":"2015-07-17T21:55:11Z"},{"id":"030ade6a-9171-4273-873e-e93de31d4b4f","api_key":"3pezRBRXdyzYW6ztfwft","info":"detail","ids":"10.1371/journal.pcbi.1003151","db_duration":13.3568,"view_duration":31.9939,"duration":45.3506,"timestamp":"2015-07-17T21:55:11Z"}]};

  it('should allow setting and retrieve chart data', function () {
    div = d3.select('body').append('div')
      .attr("id", "description");
  });
});
