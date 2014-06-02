//= require articles/show

describe("articles show", function() {

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

  describe("formattedAuthor", function() {

    it("no author", function() {
      expect(formattedAuthor([])).toEqual("");
    });

    it("one author", function() {
      var author = [{ "family": "Hull", "given": "Duncan" }];
      expect(formattedAuthor(author)).toEqual("Duncan Hull");
    });

    it("two authors", function() {
      var author = [{ "family": "Harmelen", "given": "F."},
                    { "family": "Kampis", "given": "G." }];
      expect(formattedAuthor(author)).toEqual("F. Harmelen & G. Kampis");
    });

    it("three authors", function() {
      var author = [{ "family": "Harmelen", "given": "F."},
                    { "family": "Kampis", "given": "G." },
                    { "family": "Börner", "given": "K." }];
      expect(formattedAuthor(author)).toEqual("F. Harmelen, G. Kampis & K. Börner");
    });

    it("more than four authors", function() {
      var author = [{ "family": "Harmelen", "given": "F."},
                    { "family": "Kampis", "given": "G." },
                    { "family": "Börner", "given": "K." },
                    { "family": "Besselaar", "given": "P." },
                    { "family": "Schultes", "given": "E." }];
      expect(formattedAuthor(author)).toEqual("F. Harmelen, G. Kampis, K. Börner, <em>et al</em>");
    });
  });

  describe("formattedType", function() {

    it("article-journal", function() {
      expect(formattedType("article-journal")).toEqual("Journal article");
    });

    it("unknown", function() {
      expect(formattedType("dataset")).toEqual("Other");
    });
  });
});
