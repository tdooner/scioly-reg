// The homepage, the view of all schedules.
// This populates the list with a bunch of EventViews
define(['collections/homepage', 'views/event', 'eventCache', 'collections/event_scores'], function(EventCollection, EventView, Cache, EventScores) {
  return Backbone.View.extend({
    eventTemplate: _.template($('#eventtemplate').html()),

    initialize: function() {
      this.eventSchedule = this.eventSchedule || new EventCollection;
      this.eventSchedule.bind('reset', this.reset, this);
      this.eventSchedule.fetch();
    },

    reset: function() {
      this.render();
    },

    render: function() {
      $("#events-go-here").html('');
      this.eventSchedule.each(this.addEvent.bind(this));
      this.eventSchedule.each(this.eagerLoadEvent.bind(this));
    },

    addEvent: function(ev) {
      $("#events-go-here").append(this.eventTemplate(ev.toJSON()));

      if (ev.id in Cache) {
        $("#event-scores-reported-" + ev.id).html(this.numTrueRankings(Cache[ev.id]));
      }
    },

    eagerLoadEvent: function(ev) {
      var id = ev.id;
      if (id in Cache) {
        return;
      }
      Cache[id] = new EventScores(id);
      Cache[id].bind('reset', this.updateLoadedStatus, this);
      Cache[id].fetch();
    },

    updateLoadedStatus: function(ev) {
      $("#event-scores-reported-" + ev.eventId).html(this.numTrueRankings(ev));
    },

    numTrueRankings: function(collection) {
      return _.filter(collection.pluck("ranking"), function(e) { return e.placement != null; }).length;
    }
  });
});
