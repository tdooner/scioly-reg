define(['models/ranking'], function(Ranking) {
  return Backbone.Collection.extend({
    model: Ranking,
    initialize: function(eventId) {
      this.eventId = eventId;
    },
    url: function() {
      return '/admin/scorecenter/events/' + this.eventId
    },
  });
});
