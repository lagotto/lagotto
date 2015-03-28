// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// Load jQuery
//= require jquery
//= require jquery_ujs
//= require jquery.bootpag.min.js
//= require ember
//= require ember-data
//= require bootstrap-sprockets
//
//= require d3/d3.js
//= require crossfilter/crossfilter.js
//= require lodash/dist/lodash.js
//
// Load common d3 helper functions
//= require bar_chart
//= require donut_chart
//= require d3_helpers
//
//= require_self
//= require ./lagotto

// for more details see: http://emberjs.com/guides/application/
Lagotto = Ember.Application.create({
  // rootElement: '#lagotto',
  LOG_TRANSITIONS: true,
  LOG_TRANSITIONS_INTERNAL: true,
  LOG_VIEW_LOOKUPS: true
});
