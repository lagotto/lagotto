//= require status/index

describe("status index", function() {

  beforeEach(function() {
    var html = setFixtures('<h1 id="api_key" data-api_key="12345">Test</h1>');
    var json = {"error":null,"data":{"articles_count":35,"sources_disabled_count":0,"alerts_last_day_count":10,"workers_count":1,"delayed_jobs_active_count":0,"responses_count":0,"events_count":3982,"requests_count":42,"users_count":1,"version":"2.13.7","couchdb_size":2867289,"mysql_size":16384,"update_date":"2014-04-19T09:23:36Z"}}
  });

  it("builds correct query string", function() {
    expect(query).toBeNull();
  });

});
