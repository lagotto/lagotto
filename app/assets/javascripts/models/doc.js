Lagotto.Doc = DS.Model.extend({
  title: DS.attr('string'),
  layout: DS.attr('string'),
  content: DS.attr(),
  updateDate: DS.attr('date')
});
