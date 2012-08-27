[![Build Status](https://secure.travis-ci.org/kevinjalbert/git_statistics.png?branch=master)](http://travis-ci.org/kevinjalbert/git_statistics)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/kevinjalbert/git_statistics)

# Instructions

### Using the gem
1. Acquire gem (`gem install git_statistics`)
2. Run `git_statistics` in any directory that is a git repository (use -h for options)

### Working with source
1. Clone the repository
2. Install dependencies (`bundle install`)
3. Run tests `bundle exec rake`
4. Build and install local gem `bundle exec rake install`

# Statistics

The following statistics are collected (organized by author name or author email):

* Total number of commits
* Total number of merge commits
* Total source line insertions
* Total source line deletions
* Total file creates
* Total file deletes
* Total file renames
* Total file copies

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
