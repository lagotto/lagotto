import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

var inflector = Ember.Inflector.inflector;
inflector.uncountable('status');

Router.map(function() {
  this.resource('works', function() {
    this.route('new');
  });
  this.resource('sources', function() {
    this.route('show');
  });
  this.resource('users', function() { });
  this.resource('alerts', function() { });
  this.resource('publishers', function() {
    this.route('new');
  });
  this.resource('docs', function() { });
  this.resource('status', function() { });
  this.resource('filters', function() { });
  this.resource('api-requests', function() { });
});

export default Router;
