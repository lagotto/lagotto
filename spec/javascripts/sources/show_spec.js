//= require sources/show

describe("sources show", function() {
    var data = getJSONFixture('articles_citeulike.json');

    describe('statusDonutViz', function () {
        var div;

        beforeEach(function () {
            div = d3.select('body').append('div').attr('id', 'chart_status');
        });

        afterEach(function () {
            div.remove();
        });

        describe('.data', function () {
            it('should allow setting and retrieve chart data', function () {
                expect(statusDonutViz(data).toBeNull());
            });
        });
    });

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
});
