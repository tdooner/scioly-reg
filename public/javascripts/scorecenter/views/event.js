define(['views/event_ranking'], function(EventRankingView) {
  return Backbone.View.extend({
    // The view of one event
    tagName: "tr",
    template: _.template($("#schedulehome").html()),

    initialize: function() { // Must pass in {model: EventScores}
      this.model.bind('reset', this.reset, this);
      this.model.fetch();
    },

    reset: function() {
      $("#scorecenter-container").html(
        this.template({
          teams: this.model.toJSON()
        })
      );
      $("#scores-go-here").html('');
      this.model.each(this.addRanking.bind(this));
    },

    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },

    addRanking: function(ranking) {
      // Important: Set the eventId of the score so it knows where to save itself
      ranking.set({ eventId: this.model.eventId });
      $("#scores-go-here").append(
        new EventRankingView({ model: ranking }).render().el
      );
    }
  });
});
