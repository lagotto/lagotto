//= require d3_helpers

describe("numberWithDelimiter", function() {

  it("for 0", function() {
    expect(numberWithDelimiter(0)).toBeNull();
  });

  it("for 100", function() {
    expect(numberWithDelimiter(100)).toEqual('100');
  });

  it("for 2,000", function() {
    expect(numberWithDelimiter(2000)).toEqual('2,000');
  });

  it("for 3,000,000", function() {
    expect(numberWithDelimiter(3000000)).toEqual('3,000,000');
  });

  it("for 4,000,000,000", function() {
    expect(numberWithDelimiter(4000000000)).toEqual('4,000,000,000');
  });
});

describe("numberToHumanSize", function() {

  it("for 0", function() {
    expect(numberToHumanSize(0)).toEqual('0 B');
  });

  it("for 100", function() {
    expect(numberToHumanSize(100)).toEqual('100 B');
  });

  it("for 2,000", function() {
    expect(numberToHumanSize(2000)).toEqual('2.0 KB');
  });

  it("for 3,000,000", function() {
    expect(numberToHumanSize(3000000)).toEqual('3.0 MB');
  });

  it("for 4,000,000,000", function() {
    expect(numberToHumanSize(4000000000)).toEqual('4.0 GB');
  });
});

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

describe("paginate", function() {

});

describe("pathForWork", function() {
  it("doi", function() {
    var id = "http://doi.org/10.5555/12345678"
    expect(pathForWork(id)).toEqual("Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("url", function() {
    var id = "http://example.com/1234"
    expect(pathForWork(id)).toEqual("Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });
});

describe("signpostsToString", function() {
  var work = { "events": { "counter": 40, "crossref": 10, "citeulike": 20, "facebook": 30 }},
      source_id = "",
      order = "";

  it("show signposts", function() {
    expect(signpostsToString(work, source_id, order)).toEqual("Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("show signposts by source", function() {
    expect(signpostsToString(work, "citeulike", order)).toEqual("CiteULike: 100 | Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("show signposts by order", function() {
    expect(signpostsToString(work, source_id, "citeulike")).toEqual("CiteULike: 100 | Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("show signposts only citations", function() {
    work = { "events": { "crossref": 10 };
    expect(signpostsToString(work, source_id, order)).toEqual("Cited: 10");
  });

  it("show signposts no events", function() {
    var work = { "events": {} };
    expect(signpostsToString(work, source_id, order)).toEqual("");
  });
});

describe("signpostsFromWork", function() {
  var work = { "events": { "counter": 40, "crossref": 10, "citeulike": 20, "facebook": 30 }};

  it("show signposts", function() {
    expect(signpostsFromWork(work)).toEqual("Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("show signposts no events", function() {
    var work = { "events": {} };
    expect(signpostsFromWork(work)).toEqual("");
  });
});

describe("relationToString", function() {
  (work, sources, relation_types)
  var work = { "source_id": "citeulike", "relation_type_id": "cites" },
      sources = [{ "id": "citeulike", "title": "CiteULike" }],
      relation_types = [{ "id": "cites", "inverse_tite": "Is cited by" }];

  it("relation", function() {
    expect(relationToString(work, sources, relation_types)).toEqual("Viewed: 40 • Cited: 10 • Saved: 20 • Discussed: 30");
  });

  it("relation no sources", function() {
    var work = { "events": {} };
    expect(relationToString(work, relation_types)).toEqual("");
  });

  it("relation no relation_types", function() {
    var work = { "events": {} };
    expect(relationToString(work, sources)).toEqual("");
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
