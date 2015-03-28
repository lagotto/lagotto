var inflector = Ember.Inflector.inflector;
inflector.uncountable('status');

Lagotto.Router.map(function() {
  this.resource('works', function() { });
  this.resource('sources', function() { });
  this.resource('docs', function() { });
  this.resource('status', function() { });
  this.resource('apiRequests', function() { });
});
