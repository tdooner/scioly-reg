// The homepage, the view of all schedules.
define(['collections/homepage', 'views/event', 'eventCache', 'collections/event_scores'], function(EventCollection, EventView, Cache, EventScores) {
  return Backbone.View.extend({
    eventTemplate: _.template($('#eventtemplate').html()),

    initialize: function() {
    },

    render: function() {
      $("#events-go-here").html('');
      this.collection.each(this.addEvent.bind(this));
    },

    addEvent: function(ev) {
      $("#events-go-here").append(this.eventTemplate(ev.toJSON()));

      $("#event-scores-reported-" + ev.id).html(ev.get('scores').length);
    },

    numTrueRankings: function(collection) {
      return _.filter(collection.pluck("ranking"), function(e) { return e.placement != null; }).length;
    }
  });
});
