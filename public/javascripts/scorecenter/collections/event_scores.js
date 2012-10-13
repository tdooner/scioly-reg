define(['models/ranking'], function(Ranking) {
  return Backbone.Collection.extend({
    model: Ranking,
    initialize: function() {
    },

    hasScores: function() {
      return this.length > 0;
    },
    topfive: function() {
      if (!this.hasScores()) {
        return [];
      }
      return _.first(_.sortBy(this.models, function(e) { return e.get('ranking').placement }), 5);
    }
  });
});
