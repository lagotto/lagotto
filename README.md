# Lagotto

[![Build Status](https://travis-ci.org/articlemetrics/lagotto.png?branch=master)](https://travis-ci.org/articlemetrics/lagotto)
[![Code Climate](https://codeclimate.com/github/articlemetrics/lagotto.png)](https://codeclimate.com/github/articlemetrics/lagotto)
[![Code Climate Test Coverage](https://codeclimate.com/github/articlemetrics/lagotto/coverage.png)](https://codeclimate.com/github/articlemetrics/lagotto)

Lagotto allows a user to aggregate relevant performance data on research articles, including how often an article has been viewed, cited, saved, discussed and recommended. The application was called Article-Level Metrics (ALM) until September 2014 and was started in March 2009 by the Open Access publisher [Public Library of Science (PLOS)](http://www.plos.org/). We are continuing to expand Lagotto because we believe that articles should be considered on their own merits, and that the impact of an individual article should not be determined by the journal in which it happened to be published. As a result, we hope that new ways of measuring and evaluating research quality (or ‘impact’) can and will evolve. To learn more about Article-Level Metrics, see the [SPARC ALM primer](http://www.sparc.arl.org/resource/sparc-article-level-metrics-primer).

## How to start developing now?

`Lagotto` uses [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) for setting up the development environment. To start developing now on your local machine (Mac OS X, Linux or Windows):

1. Install Vagrant: https://www.vagrantup.com/downloads.html
1. Install Virtualbox: https://www.virtualbox.org/wiki/Downloads
2. Clone this repository `git clone git@github.com:articlemetrics/lagotto.git`
3. Cd into it
4. Copy the file `.env.example` to `.env` and make any changes to the configuration as needed
5. Run `vagrant up`

Once the setup is complete (it might take up to 15 minutes), you'll be able to open up a browser and navigate to [http://10.2.2.4](http://10.2.2.4), and you should see this screen:

![Lagotto screenshot](https://github.com/articlemetrics/lagotto/blob/master/public/images/start.png)

## Documentation

Detailed instructions on how to start developing are [here](https://github.com/articlemetrics/lagotto/blob/master/docs/installation.md). There is extensive documentation - including installation instructions - at the [project website](http://articlemetrics.github.io).

## Follow @plosalm on Twitter
You should follow [@plosalm][follow] on Twitter for announcements and updates.

[follow]: https://twitter.com/plosalm

## Discussion Forum
Please direct questions about the application to the [discussion forum].

[discussion forum]: http://discuss.lagotto.io

## Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
Lagotto is released under the [MIT License](https://github.com/articlemetrics/lagotto/blob/master/LICENSE.md).
