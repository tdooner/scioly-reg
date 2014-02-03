$(document).on('page:load', function(e) {
  window._gaq.push(['_trackPageview']);
  window.mixpanel.track_pageview();
});
