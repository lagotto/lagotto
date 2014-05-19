//= require articles/index

describe("articles index", function() {

  describe("datePartsToDate", function() {

    it("year, month, day", function() {
      expect(datePartsToDate([2014, 4, 20])).toEqual(new Date(2014, 3, 20, 12));
    });

    it("year, month", function() {
      expect(datePartsToDate([2014, 4])).toEqual(new Date(2014, 3, 1, 12));
    });

    it("year", function() {
      expect(datePartsToDate([2014])).toEqual(new Date(2014, 0, 1, 12));
    });

    it("no date part", function() {
      expect(datePartsToDate([])).toBeNull();
    });
  });

  describe("formattedDate", function() {

    it("year, month, day", function() {
      expect(formattedDate(new Date(2014, 3, 20, 12), 3)).toEqual("April 20, 2014");
    });

    it("year, month", function() {
      expect(formattedDate(new Date(2014, 3, 20, 12), 2)).toEqual("April 2014");
    });

    it("year", function() {
      expect(formattedDate(new Date(2014, 3, 20, 12), 1)).toEqual("2014");
    });
  });
});
