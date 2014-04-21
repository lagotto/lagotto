//= require articles/alm

describe("articles alm", function() {

  beforeEach(function() {
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
      groups: [{ name: "viewed", display_name: "Viewed" },
               { name: "cited", display_name: "Cited" },
               { name: "saved", display_name: "Saved" },
               { name: "discussed", display_name: "Discussed" },
               { name: "recommended", display_name: "Recommended" }]
    };
    var data = {"property1":"value1", "array1":[1,2,3]};
  });

//   it("should work for objects", function() {
//     var foo = {
//       a: 12,
//       b: 34
//     };
//     var bar = {
//       a: 12,
//       b: 34
//     };
//     expect(foo).toEqual(bar);
//   });

//   it("builds correct query string", function() {
//     expect(query).toBeNull();
//   });
// });

// describe('AlmViz', function () {
//     var div,
//         chart,
//         data = [
//             {x: 0, y: 0},
//             {x: 1, y: 3},
//             {x: 2, y: 6}
//         ];

//     beforeEach(function () {
//         div = d3.select('body').append('div');
//         chart = AlmViz(div);
//     });

//     afterEach(function () {
//         div.remove();
//     });

//     describe('.data', function () {
//         it('should allow setting and retrieve chart data', function () {
//             expect(chart.data(data).data()).toBe(data);
//         });
// });
});
