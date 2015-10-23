# Lagotto

[![Build Status](https://travis-ci.org/lagotto/lagotto.png?branch=master)](https://travis-ci.org/lagotto/lagotto)
[![Code Climate](https://codeclimate.com/github/lagotto/lagotto.png)](https://codeclimate.com/github/lagotto/lagotto)
[![Code Climate Test Coverage](https://codeclimate.com/github/lagotto/lagotto/coverage.png)](https://codeclimate.com/github/lagotto/lagotto)
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.20046.svg)](http://doi.org/10.5281/zenodo.20046)

Lagotto allows a user to track events around research articles and other scholarly outputs, including how often a work has been viewed, cited, saved, discussed and recommended. The application was started in March 2009 by the Open Access publisher [Public Library of Science (PLOS)](http://www.plos.org/). Visit the [Lagotto website](http://lagotto.io) to learn more.

## How to start developing now?

`Lagotto` uses [Vagrant](https://www.vagrantup.com/) and [Virtualbox](https://www.virtualbox.org/) for setting up the development environment. To start developing now on your local machine (Mac OS X, Linux or Windows):

1. Install Vagrant: https://www.vagrantup.com/downloads.html
1. Install Virtualbox: https://www.virtualbox.org/wiki/Downloads
2. Clone this repository `git clone git@github.com:lagotto/lagotto.git`
3. Cd into it
4. Copy the file `.env.example` to `.env` and make any changes to the configuration as needed
5. Run `vagrant up`

Once the setup is complete (it might take up to 15 minutes), you'll be able to open up a browser and navigate to [http://10.2.2.4](http://10.2.2.4), and you should see this screen:

![Lagotto screenshot](https://github.com/lagotto/lagotto/blob/master/public/images/start.png)

## Documentation

Detailed instructions on how to start developing are [here](https://github.com/lagotto/lagotto/blob/master/docs/installation.md). There is extensive documentation - including installation instructions - at the [Lagotto website](http://lagotto.io).

## Discussion
Please direct questions about the application to the [discussion forum](http://discuss.lagotto.io). Use the [Github Issue Tracker](https://github.com/lagotto/lagotto/issues) to follow the ongoing development, or use the [Waffle Board](https://waffle.io/lagotto/lagotto) for a development overview.

[![Stories in Progress](https://badge.waffle.io/lagotto/lagotto.svg?label=in%20progress&title=In%20Progress)](https://waffle.io/lagotto/lagotto)

## Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
Lagotto is released under the [MIT License](https://github.com/lagotto/lagotto/blob/master/LICENSE.md).
