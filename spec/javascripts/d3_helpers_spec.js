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

describe("paginateEvents", function() {

});

describe("paginate", function() {

});

describe("urlForWork", function() {

  it("doi", function() {
    var work = { "doi": "10.1371/journal.pone.0043007" };
    expect(urlForWork(work)).toEqual("http://dx.doi.org/10.1371/journal.pone.0043007");
  });

  it("pmid", function() {
    var work = { "pmid": "17183658" };
    expect(urlForWork(work)).toEqual("http://www.ncbi.nlm.nih.gov/pubmed/17183658");
  });

  it("pmcid", function() {
    var work = { "pmcid": "1762328" };
    expect(urlForWork(work)).toEqual("http://www.ncbi.nlm.nih.gov/pmc/works/PMC1762328");
  });

  it("ark", function() {
    var work = { "ark": "ark:/13030/m5br8stc" };
    expect(urlForWork(work)).toEqual("http://n2t.net/ark:/13030/m5br8stc");
  });

  it("canonical_url", function() {
    var work = { "canonical_url": "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0043007" };
    expect(urlForWork(work)).toEqual("http://www.plosone.org/article/info:doi/10.1371/journal.pone.0043007");
  });

  it("no pid", function() {
    var work = {};
    expect(urlForWork(work)).toEqual("");
  });

});

describe("signpostsToString", function() {
  var work = { "cited": 10, "saved": 20, "discussed": 30, "viewed": 40,
               "sources": [{ "name": "citeulike", "title": "CiteULike", "metrics": { "total": 100 }}] },
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
    work = { "cited": 10, "saved": 0, "discussed": 0, "viewed": 0,
             "sources": [{ "name": "citeulike", "title": "CiteULike", "metrics": { "total": 10 }}] };
    expect(signpostsToString(work, source_id, order)).toEqual("Cited: 10");
  });

  it("show signposts no events", function() {
    work = { "cited": 0, "saved": 0, "discussed": 0, "viewed": 0,
             "sources": [{ "name": "citeulike", "title": "CiteULike", "metrics": { "total": 0 }}] };
    expect(signpostsToString(work, source_id, order)).toEqual("");
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
