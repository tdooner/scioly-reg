define(['models/event'], function(Event) {
  return Backbone.Collection.extend({
      model: Event,
      url: '/admin/scorecenter/events'
  });
});
