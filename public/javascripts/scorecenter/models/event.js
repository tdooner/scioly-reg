define(['models/ranking', 'collections/event_scores'], function(Ranking, EventScores) {
  return Backbone.RelationalModel.extend({
    relations: [{
      type: Backbone.HasMany,
      key: 'scores',
      relatedModel: Ranking,
      collectionType: EventScores,
      reverseRelation: {
        key: 'event',
        includeInJSON: 'id'
      }
    }],
  });
});
