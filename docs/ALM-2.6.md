ALM 2.6 was released on March 19, 2013. The development work focused on two areas: API performance and easy installation.

### API Performance

The API code was refactored, adding the [Draper Decorator](https://github.com/drapergem/draper) between the model and the [RABL Views](https://github.com/nesquena/rabl). We added caching, using Russian Doll fragment caching as described [here](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works). It required some extra work to make this work with RABL and Draper. We also added a visualization of API requests to the admin dashboard, using d3.js and the [crossfiler](http://square.github.com/crossfilter/) library.

### Easy Installation

To make it easier to install the ALM application, we have updated and throughoutly tested the [manual installation](installation) instructions, updated the Chef / Vagrant automated installation (now using Ubuntu 12.04 and linking directly to the Chef Cookbook repository), and provided a VMware image of ALM application (535 MB [download](http://dl.dropbox.com/u/9406373/alm_ubuntu_12.04_vmware.tar.gz), username/password: alm). The VMware image file is still experimental and feedback is appreciated.

An updated version of [Vagrant](http://docs.vagrantup.com/v2/getting-started/index.html) (1.1) was released days after ALM 2.6, and this version now supports VMware and AWS. We will support these platforms in a future ALM release to again make it easier to test or install the ALM application.

### Other Changes

This release includes many small fixes and improvements. Of particular interest are the RSS feeds for the most popular articles by source, published in the last 7 days, 30 days, 12 months, or all-time. The RSS feeds are link from the most-cited lists for each source, e.g. [here](http://alm.plos.org/sources/twitter).