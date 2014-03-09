//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require nav
//= require bootstrap-tabs
//= require bootstrap-tabs-autoselect
//= require bootstrap.min
//= require jquery.tablesorter.min
//= require analytics
//= require nprogress

$(document).on('page:fetch',   function() { NProgress.start(); });
$(document).on('page:change',  function() { NProgress.done(); });
$(document).on('page:restore', function() { NProgress.remove(); });
