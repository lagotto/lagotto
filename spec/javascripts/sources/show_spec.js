//= require sources/show

describe("sources show", function() {
  var json = {"meta":{"status":"ok","message-type":"source","message-version":"6.0.0"},"source":{"id":"mendeley","title":"Mendeley","group_id":"saved","description":"Mendeley is a reference manager and social bookmarking tool.","state":"waiting","error_count":0,"work_count":129398,"event_count":2888117,"status":{"refreshed":129614,"queued":37774,"stale":62},"responses":{"count":12258,"average":2847,"maximum":8384},"by_day":{"with_events":8265,"without_events":5208,"not_updated":153977},"by_month":{"with_events":129398,"without_events":32062,"not_updated":5990},"timestamp":"2015-07-17T21:07:34Z"}};

  describe('statusDonutViz', function () {
    var div;

    beforeEach(function () {
      div = d3.select('body').append('div').attr('id', 'chart_status');
    });

    afterEach(function () {
      div.remove();
    });

    // describe('data', function () {
    //     it('should allow setting and retrieve chart data', function () {
    //         expect(statusDonutViz(json).toBeNull());
    //     });
    // });
  });
});
