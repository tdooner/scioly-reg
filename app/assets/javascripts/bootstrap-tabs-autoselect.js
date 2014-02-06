// Selects a tab by default
$(function() {
  var prefix = '#tab-';
  if (window.location.hash.indexOf(prefix) == 0) {
    var tabName = window.location.hash.split(prefix)[1];
    $('.tabs li').removeClass('active');
    $('.tab-content div').removeClass('active');
    $('.tabs li [href=#' + tabName +']').parent().addClass('active');
    $('#' + tabName).addClass('active');
  }
});
