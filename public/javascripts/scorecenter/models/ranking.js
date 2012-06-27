define([], function() {
  return Backbone.Model.extend({
    url: function() {
      return "/admin/scorecenter/events/" + this.get('eventId') + "/placings/" + this.get('team').id
    },
  });
});
