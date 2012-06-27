define(['views/homepage', 'collections/event_scores', 'views/event', 'eventCache'], function(HomepageEventCollection, EventScores, EventView, Cache) {
  return Backbone.Router.extend({
    routes: {
      "": "home",
      "/": "home",
      "event/:event_id/scores": "eventScores"
    },

    home: function() {
      $("#scorecenter-container").html(
        _.template($("#scoreCenterHome").html())
      );

      if (!this.homepage) {
        this.homepage = new HomepageEventCollection;
      }
      this.homepage.render();
    },

    eventScores: function(id) {
      Cache[id] = Cache[id] || new EventScores(id);
      var theEventView = new EventView({ model: Cache[id] });
    },
  });
});
