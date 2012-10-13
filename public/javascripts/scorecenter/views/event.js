define(['views/event_ranking'], function(EventRankingView) {
  return Backbone.View.extend({
    // The view of one event
    tagName: "tr",
    template: _.template($("#schedulehome").html()),

    initialize: function() { // Must pass in {collection: EventScores}
    },

    render: function() {
      $("#scorecenter-container").html(
        this.template({
          teams: this.model.get('scores') //TODO: This is the wrong number
        })
      );
      $("#scores-go-here").html(''); // TODO: remove reliance on this element
      this.model.get('scores').each(this.addRanking.bind(this));
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
