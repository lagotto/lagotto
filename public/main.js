requirejs.config({
    appDir: ".",
    baseUrl: "js",
    paths: { 
        'jquery': ['//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min'],
        'bootstrap': ['//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min'],
        'embed': ['http://alm-plos.local/embed']
    },
    shim: {
        /* Set dependencies */
        'bootstrap' : ['jquery']
    }
});

require([
    'jquery', 'bootstrap', 'embed'
],
function(){
    loadCss();
    return {};
});

function loadCss() {
    var link = document.createElement("link");
    link.type = "text/css";
    link.rel = "stylesheet";
    link.href = "//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css";
    document.getElementsByTagName("head")[0].appendChild(link);
}