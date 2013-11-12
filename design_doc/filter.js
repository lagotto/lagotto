{
   "_id": "_design/filter",
   "language": "javascript",
   "views": {
       "html_ratio": {
           "map": "function(doc) {
                     if (doc.source == 'counter')
                       last_month = doc.events.slice(-1)[0];
                       html = parseInt(last_month[\"html_views\"]);
                       pdf = last_month[\"pdf_views\"] > 0 ? last_month[\"pdf_views\"] : 1;
                       ratio = Math.floor( html / pdf * 100) / 100;
                       if (html >= 50 && ratio >= 50 && doc.doc_type == 'current')
                         emit(doc.retrieved_at, { \"html\": html, \"ratio\": ratio });
                   }"
       }
   }
}