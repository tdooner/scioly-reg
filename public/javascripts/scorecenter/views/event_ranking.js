define([], function() {
  return Backbone.View.extend({
    tagName: "tr",
    template: _.template($("#rankingtemplate").html()),

    events: {
      "change .placement-input":  "updateScore",
    },

    updateScore: function() {
      var field = this.$el.find(".placement-input");
      field.attr('disabled', true).parent().addClass("warning").removeClass("error");
      this.model.save({ placement: field[0].value }, {
        success: function() {
          field.attr('disabled', false).parent().removeClass("warning");
          this.render();
        }.bind(this),
        error: function() {
          //field.attr('disabled', false).parent().removeClass("warning").addClass("error");
        }.bind(this),
        wait: true
      });
    },

    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this
    }
  });
});
