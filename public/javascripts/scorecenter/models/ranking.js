define([], function() {
  return Backbone.RelationalModel.extend({
    url: function() {
      return "/admin/scorecenter/events/" + this.get('event').id + "/placings/" + this.get('team').id
    },
  });
});
