Lagotto.DocRoute = Ember.Route.extend({
  model: function() { return this.store.find('doc'); }
});
