//= require status/index

describe("status index", function() {

  // beforeEach(function() {
  //   var html = setFixtures('<h1 id="api_key" data-api_key="12345">Test</h1>');
  var data = {"error":null,"data":{"articles_count":35,"sources_disabled_count":0,"alerts_last_day_count":10,"workers_count":1,"delayed_jobs_active_count":0,"responses_count":0,"events_count":3982,"requests_count":42,"users_count":1,"version":"2.13.7","couchdb_size":2867289,"mysql_size":16384,"update_date":"2014-04-19T09:23:36Z"}};
  // });

  describe("numberToHumanSize", function() {

    it("for 100", function() {
      expect(numberToHumanSize(100)).toEqual('100 B');
    });

    it("for 2,000", function() {
      expect(numberToHumanSize(2000)).toEqual('2.0 kB');
    });

    it("for 3,000,000", function() {
      expect(numberToHumanSize(3000000)).toEqual('3.0 MB');
    });

    it("for 4,000,000,000", function() {
      expect(numberToHumanSize(4000000000)).toEqual('4.0 GB');
    });
  });

//   it("builds correct query string", function() {
//     expect(query).toBeNull();
//   });

});
