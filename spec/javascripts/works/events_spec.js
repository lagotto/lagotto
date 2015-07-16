//= require works/alm

describe("works events", function() {

  var json = {"total":1,"total_pages":1,"page":1,"error":null,"data":[{"doi":"10.1371/journal.pone.0048985","title":"Kretzoiarctos gen. nov., the Oldest Member of the Giant Panda Clade","canonical_url":"http://www.plosone.org/article/info:doi/10.1371/journal.pone.0048985","mendeley_uuid":"15e7e73b-985a-3cf6-baa9-d1151a7f6371","pmid":"23155439","pmcid":"3498366","issued":{"date-parts":[[2012,11,14]]},"viewed":0,"saved":19,"discussed":155,"cited":2,"update_date":"2014-07-20T21:34:09Z","sources":[{"name":"crossref","title":"CrossRef","group_name":"cited","events_url":null,"by_day":[],"by_month":[{"year":2014,"month":7,"total":2}],"by_year":[{"year":2014,"total":2}],"update_date":"2014-07-20T21:33:59Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":2}},{"name":"mendeley","title":"Mendeley","group_name":"saved","events_url":"http://www.mendeley.com/research/kretzoiarctos-gen-nov-oldest-member-giant-panda-clade/","by_day":[],"by_month":[{"year":2014,"month":7,"total":19}],"by_year":[{"year":2014,"total":19}],"update_date":"2014-07-20T21:33:58Z","metrics":{"pdf":null,"html":null,"readers":19,"comments":null,"likes":null,"total":19}},{"name":"facebook","title":"Facebook","group_name":"discussed","events_url":null,"by_day":[],"by_month":[{"year":2014,"month":7,"total":155}],"by_year":[{"year":2014,"total":155}],"update_date":"2014-07-20T21:33:57Z","metrics":{"pdf":null,"html":null,"readers":48,"comments":37,"likes":70,"total":155}},{"name":"twitter_search","title":"Twitter","group_name":"discussed","events_url":"https://twitter.com/search?q=10.1371%2Fjournal.pone.0048985","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:33:58Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":0,"likes":null,"total":0}},{"name":"citeulike","title":"CiteULike","group_name":"saved","events_url":"http://www.citeulike.org/doi/10.1371%2Fjournal.pone.0048985","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:33:56Z","metrics":{"pdf":null,"html":null,"readers":0,"comments":null,"likes":null,"total":0}},{"name":"pubmed","title":"PubMed Central","group_name":"cited","events_url":"http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=23155439","by_day":[],"by_month":[{"year":2014,"month":7,"total":3}],"by_year":[{"year":2014,"total":3}],"update_date":"2014-07-20T21:34:01Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":3}},{"name":"wordpress","title":"Wordpress.com","group_name":"discussed","events_url":"http://en.search.wordpress.com/?q=\"10.1371%2Fjournal.pone.0048985\"&t=post","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:34:00Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":0}},{"name":"reddit","title":"Reddit","group_name":"discussed","events_url":"http://www.reddit.com/search?q=\"10.1371%2Fjournal.pone.0048985\"","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:33:57Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":0,"likes":0,"total":0}},{"name":"wikipedia","title":"Wikipedia","group_name":"discussed","events_url":"http://en.wikipedia.org/w/index.php?search=\"10.1371%2Fjournal.pone.0048985\"","by_day":[],"by_month":[{"year":2014,"month":7,"total":9}],"by_year":[{"year":2014,"total":9}],"update_date":"2014-07-20T21:34:09Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":9}},{"name":"datacite","title":"DataCite","group_name":"cited","events_url":"http://search.datacite.org/ui?q=relatedIdentifier:10.1371%2Fjournal.pone.0048985","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:33:59Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":0}},{"name":"pmceurope","title":"Europe PubMed Central","group_name":"cited","events_url":"http://europepmc.org/abstract/MED/23155439#fragment-related-citations","by_day":[],"by_month":[{"year":2014,"month":7,"total":3}],"by_year":[{"year":2014,"total":3}],"update_date":"2014-07-20T21:34:00Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":3}},{"name":"pmceuropedata","title":"Europe PubMed Central Database Citations","group_name":"cited","events_url":"http://europepmc.org/abstract/MED/23155439#fragment-related-bioentities","by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:34:01Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":0}},{"name":"nature","title":"Nature Blogs","group_name":"discussed","events_url":null,"by_day":[],"by_month":[],"by_year":[],"update_date":"2014-07-20T21:33:57Z","metrics":{"pdf":null,"html":null,"readers":null,"comments":null,"likes":null,"total":0}}]}]};
  var options = {
    baseUrl: '',
    minItemsToShowGraph: {
        minEventsForYearly: 3,
        minEventsForMonthly: 3,
        minEventsForDaily: 3,
        minYearsForYearly: 1,
        minMonthsForMonthly: 1,
        minDaysForDaily: 1
    },
    vizDiv: "#metrics",
    showTitle: false,
    groups: [{ name: "viewed", title: "Viewed" },
             { name: "cited", title: "Cited" },
             { name: "saved", title: "Saved" },
             { name: "discussed", title: "Discussed" },
             { name: "recommended", title: "Recommended" }]
  };

  it('should allow setting and retrieve chart data', function () {
    div = d3.select('body').append('div')
      .attr("id", "metrics");
    options['almStatsJson'] = json["data"];

    var almviz = new AlmViz(options);
    almviz.initViz();
  });

});
