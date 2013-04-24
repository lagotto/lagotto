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
             setErrorMessage(tag, 'an error occured while fetching the data.');
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
}

main();