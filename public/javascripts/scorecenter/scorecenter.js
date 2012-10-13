define(['views/homepage', 'collections/event_scores', 'views/event', 'eventCache', 'views/slideshow', 'models/event'], function(HomepageEventView, EventScores, EventView, Cache, SlideshowView, Event) {
  return Backbone.Router.extend({
    routes: {
      "": "home",
      "/": "home",
      "event/:event_id/scores": "eventScores",
      "slideshow": "slideshow"
    },

    initialize: function() {
      var TournamentCollection = Backbone.Collection.extend({ model: Event })
      this.tournament = new TournamentCollection();

      var theEvent;
      for (i in globalData) {
        theEvent = globalData[i];
        this.tournament.add(new Event(theEvent));
      }
    },

    home: function() {
      $("#scorecenter-container").html(
        _.template($("#scoreCenterHome").html())
      );

      this.homepage = new HomepageEventView({ collection: this.tournament });
      this.homepage.render();
    },

    eventScores: function(id) {
      var theEventView = new EventView({ model: this.tournament.get(id) });
      theEventView.render();
    },

    slideshow: function() {
    /*
      var theSlideshow = new SlideshowView();
      $("body").append(theSlideshow.render().el);
      $("body").css('overflow', 'hidden');
      */
    }
  });
});
