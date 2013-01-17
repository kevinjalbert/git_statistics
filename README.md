[![Build Status](https://secure.travis-ci.org/kevinjalbert/git_statistics.png?branch=master)](http://travis-ci.org/kevinjalbert/git_statistics)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/kevinjalbert/git_statistics)

# Instructions

### Using the gem
1. Acquire gem (`gem install git_statistics`)
2. Run `git statistics` in any directory that is a git repository (use -h for options)

### Working with source
1. Clone the repository
2. Install dependencies (`bundle install`)
3. Run tests `bundle exec rake`
4. Build and install local gem `bundle exec rake install`

# Functions

This gem will analyze every commit within a git repository using `git log` and [mojombo/grit](https://github.com/mojombo/grit). The following author statistics in relation to the git repository are collected and displayed:

* Total number of commits
* Total number of merge commits
* Total source line additions
* Total source line deletions
* Total file creates
* Total file deletes
* Total file renames
* Total file copies

This gem also uses [github/linguist](https://github.com/github/linguist) to determine the language of each individual file within commits. This augments the reported statistics by breaking down the author's statistics by languages.

This gem also has the ability to save the acquired data into a JSON file (in either a compressed or pretty format). If a saved file is present for the repository you can use the gem to load the data from the file, thus saving time for re-displaying the statistics using a different set of display flags (what statistic to sort on, number of authors to show, consider merges, etc...). In the event that a repository updates with new commits the gem allows you to update the saved file with the new commits.

# Example Output
The following is the output produced by *git_statistics* when used on the [pengwynn/octokit](https://github.com/pengwynn/octokit) (at commit [95a9de3](https://github.com/pengwynn/octokit/commit/95a9de325bee4ca03c9c1d61de2d643666c90037)) git repository. In this output we show the top three authors in rankings based on number of commits (merge commits are excluded from these results).

![screenshot](http://cloud.github.com/downloads/kevinjalbert/git_statistics/pengwynn_octokit_output.png)

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
