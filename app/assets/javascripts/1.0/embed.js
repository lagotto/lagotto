/* ===========================================================
 * embed.js v1.0
 * http://github.com/articlemetrics/alm
 *
 * Modified from code by Alex Marandon
 * http://alexmarandon.com/articles/web_widget_jquery/
 * ===========================================================
 * Copyright 2013 Public Library of Science
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */

(function() {

// Localize jQuery variable
var jQuery;

// Find host for this script
var script = $('script').last();
//var host = (script.src).split('/')[2];

/******** Load Bootstrap if not present *********/
if (! $('body').popover) {
    var script_tag = document.createElement('script');
    script_tag.setAttribute("type","text/javascript");
    script_tag.setAttribute("src","http://www.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js");
    script_tag.appendTo('head'); 
        
    var css_tag = document.createElement("link");
    css_tag.setAttribute("rel", "stylesheet");
    css_tag.setAttribute("type", "text/css");
    css_tag.setAttribute("href", "http://www.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css");
    css_tag.appendTo('head'); 
}

/******** Load jQuery if not present *********/
if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.8.3') {
    var script_tag = document.createElement('script');
    script_tag.setAttribute("type","text/javascript");
    script_tag.setAttribute("src",
        "http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js");
    if (script_tag.readyState) {
      script_tag.onreadystatechange = function () { // For old versions of IE
          if (this.readyState == 'complete' || this.readyState == 'loaded') {
              scriptLoadHandler();
          }
      };
    } else { // Other browsers
      script_tag.onload = scriptLoadHandler;
    }
    // Try to find the head, otherwise default to the documentElement
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
} else {
    // The jQuery version on the window is the one we want to use
    jQuery = window.jQuery;
    main();
}

/******** Called once jQuery has loaded ******/
function scriptLoadHandler() {
    // Restore $ and window.jQuery to their previous values and store the
    // new jQuery in our local jQuery variable
    jQuery = window.jQuery.noConflict(true);
    // Call our main function
    main(); 
}

/******** Get identifier from data attribute ********/
function getIdentifier(tag) {
  var value = tag.data('doi');
  var type = "doi";

  if (! value) {
      var value = tag.data('pmid');
      var type = "pmid";
  } else if (! value) {
      var value = tag.data('pmcid');
      var type = "pmcid";
  } else if (! value) {
      var value = tag.data('mendeley');
      var type = "mendeley";
  }
  return { 'value': value, 'type': type }
}

/******** Create HTML for large widget ********/
function setSmallWidget(tag, data) {
    $('.alm-signpost').popover();
    if (data["views"] > 0 || tag.data('show-zero')) tag.append('<span class="alm-signpost alm-views label label-info" title="Twitter Bootstrap Popover" data-views="' + data["views"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["views"] + ' Views</span>');
    if (data["shares"] > 0 || tag.data('show-zero')) tag.append(' <span class="alm-signpost alm-shares label label-info" title="Twitter Bootstrap Popover" data-shares="' + data["shares"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["shares"] + ' Shares</span>');
    if (data["bookmarks"] > 0 || tag.data('show-zero')) tag.append(' <span class="alm-signpost alm-bookmarks label label-info" title="Twitter Bootstrap Popover" data-bookmarks="' + data["bookmarks"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["bookmarks"] + ' Bookmarks</span>');
    if (data["citations"] > 0 || tag.data('show-zero')) tag.append(' <span class="alm-signpost alm-citations label label-info" title="Twitter Bootstrap Popover" data-citations="' + data["citations"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["citations"] + ' Citations</span>');
    if (tag.data('coins')) tag.append(' <span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/' + data["doi"] + '&amp;rft.genre=article&amp;rft.atitle=' + encodeURIComponent(data["title"]).replace(/%20/g, '+') + '&amp;rft_date=' + data["publication_date"] + '"></span>');
}

/******** Create HTML for large widget ********/
function setLargeWidget(tag, data) {
    tag.width(100);
    $('.alm-signpost').popover();
    if (data["views"] > 0 || tag.data('show-zero')) tag.append('<div class="alm-signpost alm-views label label-info" title="Twitter Bootstrap Popover" data-views="' + data["views"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["views"] + ' Views</div>');
    if (data["shares"] > 0 || tag.data('show-zero')) tag.append(' <div class="alm-signpost alm-shares label label-info" title="Twitter Bootstrap Popover" data-shares="' + data["shares"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["shares"] + ' Shares</div>');
    if (data["bookmarks"] > 0 || tag.data('show-zero')) tag.append(' <div class="alm-signpost alm-bookmarks label label-info" title="Twitter Bootstrap Popover" data-bookmarks="' + data["bookmarks"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["bookmarks"] + ' Bookmarks</div>');
    if (data["citations"] > 0 || tag.data('show-zero')) tag.append(' <div class="alm-signpost alm-citations label label-info" title="Twitter Bootstrap Popover" data-citations="' + data["citations"] + '" data-content="It\'s so simple to create a tooltop for my website!">' + data["citations"] + ' Citations</div>');
    if (tag.data('coins')) tag.append(' <span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/' + data["doi"] + '&amp;rft.genre=article&amp;rft.atitle=' + encodeURIComponent(data["title"]).replace(/%20/g, '+') + '&amp;rft_date=' + data["publication_date"] + '"></span>');
}

/******** Create error message ********/
function setErrorMesage(tag, message) {
    tag.html('<div class="alert"><button type="button" class="close" data-dismiss="alert">&times;</button>Error: ' + message + '</div')
}

/******** Our main function ********/
function main() { 
    jQuery(document).ready(function($) {         
        // Loop through all embed snippets         
        $('.alm-embed').each(function (i) {
            var tag = $(this);
            var id = getIdentifier(tag);
            // Proceed if calling API for data only if we have an identifier
            if (! id.value) {
                setErrorMessage(tag, 'no identifier found.');
                return;
            } 
            
            var jsonp_url = "http://alm.local/api/v3/articles?callback=?";
            $.getJSON(jsonp_url, { ids: id.value, type: id.type, info: "summary" }, function(data) {
                 // clearTimeout(errorTimeout);
                 if ($.isArray(data)) {
                     if (tag.prop('tagName') == "DIV") {
                         setLargeWidget(tag, data[0]);
                     } else {
                         setSmallWidget(tag, data[0]);
                     }
                 } else {
                     setErrorMessage(tag, 'an error occured while fetching the data.');
                 }
            });
        });
    });
}

})(); // We call our anonymous function immediately