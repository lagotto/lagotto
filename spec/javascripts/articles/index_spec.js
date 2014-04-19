//= require jquery
//= require helpers/jasmine-fixture
//= require d3
//= require articles/index

describe("articles index", function() {

  beforeEach(function() {
    affix('h1#api_key[data-api_key="12345"]')
  });

  describe("data attributes", function() {
    it("builds correct query string", function() {
      expect(query).toBeNull();
    });
  });
});

// describe("datePartsToDate", function() {
//   it("contains spec with an expectation", function() {
//     expect(datePartsToDate([2014,4,17])).toEqual("12345");
//   });
// });

// setFixtures(sandbox({class: 'my-class'}))
// $('#sandbox').myTestedClassRemoverPlugin()
// expect($('#sandbox')).not.toHaveClass('my-class')

// describe('BarChart', function () {
//     var div,
//         chart,
//         data = [
//             {x: 0, y: 0},
//             {x: 1, y: 3},
//             {x: 2, y: 6}
//         ];

//     beforeEach(function () {
//         div = d3.select('body').append('div');
//         chart = BarChart(div);
//     });

//     afterEach(function () {
//         div.remove();
//     });

//     describe('.data', function () {
//         it('should allow setting and retrieve chart data', function () {
//             expect(chart.data(data).data()).toBe(data);
//         });
// });
// });

// function BarChart(p) {
// var that = {};
// var _parent = p, data;
// that.data = function (d) {
//         if (!arguments.length) return _data;
//         _data = d;
//         return that;
// };

// return that;
// }
