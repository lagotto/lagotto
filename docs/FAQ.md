Please add questions that are not listed here to the [Issue Tracker](https://github.com/articlemetrics/alm/issues).

### Where can I ask questions regarding the ALM application?
Please create an issue in the [Issue Tracker](https://github.com/articlemetrics/alm/issues) or ask your question in the [PLOS API Developer Google Group](https://groups.google.com/forum/?fromgroups#!forum/plos-api-developers).

### How do I create more than one user?
The first admin user can be created by attempting to login. If you need to create additional users, you can do so from the console:

    $ rails c

In that console, execute the following line of code:

    >> u = User.create(:login => "admin", :email => "admin@example.org", :password => "adminadmin", :password_confirmation => "adminadmin")

Then, if you do `>> User.all` it'll show you all user objects. If the user object isn't in the list, most likely the password was rejected. Passwords need to be at least 6 characters.

### Where do I find videos and presentations about ALM?
Several videos and presentations are available at the [PLOS ALM website](http://article-level-metrics.plos.org/videos).

### What other organizations are using the ALM application?
Please contact us if you are using the ALM application and want your organization to be listed here.

### What other services provide Article-Level Metrics?
Article-Level Metrics is a very dynamic area, as of May 2013 the following organizations also provide comprehensive ALM data:

* [altmetric.com](http://altmetric.com)
* [ImpactStory](http://impactstory.org)
* [Plum Analytics](http://www.plumanalytics.com)