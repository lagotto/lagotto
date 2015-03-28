Lagotto.Status = DS.Model.extend({
  worksCount: DS.attr('number'),
  worksNewCount: DS.attr('number'),
  eventsCount: DS.attr('number'),
  responsesCount: DS.attr('number'),
  requestsCount: DS.attr('number'),
  alertsCount: DS.attr('number'),
  usersCount: DS.attr('number'),
  sourcesActiveCount: DS.attr('number'),
  version: DS.attr('string'),
  outdatedVersion: DS.attr('boolean'),
  couchdbSize: DS.attr('number'),
  updateDate: DS.attr('date')
});
