//= require articles/index

describe("articles index", function() {

    describe("datePartsToDate", function() {

        it("year, month, day", function() {
            expect(datePartsToDate([2014, 4, 20])).toEqual('April 20, 2014');
        });

        it("year, month", function() {
            expect(datePartsToDate([2014, 4])).toEqual('April 2014');
        });

        it("year", function() {
            expect(datePartsToDate([2014])).toEqual('2014');
        });

        it("no date part", function() {
            expect(datePartsToDate([])).toBeNull();
        });
    });
});
