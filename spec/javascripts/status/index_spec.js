//= require jquery
//= require helpers/jasmine-fixture
//= require d3
//= require status/index

describe("status index", function() {

  beforeEach(function() {
    affix('h1#api_key[data-api_key="12345"]')
  });

  it("builds correct query string", function() {
    expect(query).toBeNull();
  });

});
