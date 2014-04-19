//= require sources/index

describe("sources index", function() {
  it("should work for objects", function() {
    var foo = {
      a: 12,
      b: 34
    };
    var bar = {
      a: 12,
      b: 34
    };
    expect(foo).toEqual(bar);
  });
});
