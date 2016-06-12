# Lagotto

[![Build Status](https://travis-ci.org/lagotto/lagotto.png?branch=master)](https://travis-ci.org/lagotto/lagotto)
[![Code Climate](https://codeclimate.com/github/lagotto/lagotto.png)](https://codeclimate.com/github/lagotto/lagotto)
[![Code Climate Test Coverage](https://codeclimate.com/github/lagotto/lagotto/coverage.png)](https://codeclimate.com/github/lagotto/lagotto)
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.49516.svg)](http://doi.org/10.5281/zenodo.49516)

Lagotto allows a user to track events around research articles and other scholarly outputs, including how often a work has been viewed, cited, saved, discussed and recommended. The application was started in March 2009 by the Open Access publisher [Public Library of Science (PLOS)](http://www.plos.org/). Visit the [Lagotto website](http://lagotto.io) to learn more.

## Installation

Using Docker.

```
docker run -p 8050:80 lagotto/lagotto
```

You can now point your browser to `http://localhost:8050` and use the application.

![Screenshot](https://raw.githubusercontent.com/lagotto/lagotto/5-1-unstable/public/images/start.png)

For a more detailed configuration, including serving the application from the host for live editing, look at `docker-compose.yml` in the root folder.

## Development

We use Rspec for unit and acceptance testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/lagotto/issues).

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**lagotto** is released under the [MIT License](https://github.com/datacite/lagotto/blob/master/LICENSE).
