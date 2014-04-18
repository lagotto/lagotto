// describe("datePartsToDate", function() {
//   it("contains spec with an expectation", function() {
//     expect(datePartsToDate([2014,4,17])).toEqual("12345");
//   });
// });

require(["app/assets/javascripts/articles/index"], function (index) {
  describe("returns titles", function() {
    it("contains spec with an expectation", function() {
      expect(index.api_key).toEqual("12345");
    });
  });
});
