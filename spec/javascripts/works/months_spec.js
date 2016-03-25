//= require works/months

describe("works months", function() {

  var json = {"meta":{"status":"ok","message-type":"work","message-version":"6.0.0"},"work":{"id":"http://doi.org/10.1371/journal.pcbi.1000204","publisher_id":340,"author":[{"family":"Hull","given":"Duncan"},{"family":"Pettifer","given":"Steve R."},{"family":"Kell","given":"Douglas B."}],"title":"Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web","issued":{"date-parts":[[2008,10,31]]},"container-title":"PLOS Computational Biology","volume":4,"page":"e1000204","issue":10,"DOI":"10.1371/journal.pcbi.1000204","URL":"http://journals.plos.org/ploscompbiol/article?id=10.1371%2Fjournal.pcbi.1000204","PMID":"18974831","PMCID":"2568856","scp":"55449101991","wos":"000261480700019","events":{"crossref":32,"pubmed":17,"scopus":61,"counter":86746,"researchblogging":7,"wos":34,"pmc":8066,"mendeley":2091,"twitter":14,"wikipedia":9,"relativemetric":504813,"figshare":14,"pmceurope":20,"wordpress":13,"articlecoverage":1,"plos_comments":14},"timestamp":"2015-07-17T10:57:12Z"}},
      work = {},
      sources = [],
      groups = [],
      options = {
        baseUrl: '',
        minItemsToShowGraph: {
          minEventsForYearly: 1,
          minEventsForMonthly: 1,
          minEventsForDaily: 1,
          minYearsForYearly: 1,
          minMonthsForMonthly: 1,
          minDaysForDaily: 1
        },
        vizDiv: "#panel-events",
        work: {},
        sources: [],
        groups: []
      };

  // it('should allow setting and retrieve chart data', function () {
  //   div = d3.select('body').append('div')
  //     .attr("id", "panel-events");

  //   options.work = work;
  //   options.sources = sources;
  //   options.groups = groups;
  //   options.almStatsJson = json.events;
  //   var almviz = new AlmViz(options);
  //   almviz.initViz();
  // });

});
