# Git Statistics

[![Gem Version](https://badge.fury.io/rb/git_statistics.svg)](http://badge.fury.io/rb/git_statistics)
[![Build Status](https://travis-ci.org/kevinjalbert/git_statistics.svg?branch=master)](http://travis-ci.org/kevinjalbert/git_statistics)
[![Coverage Status](https://img.shields.io/coveralls/kevinjalbert/git_statistics.svg)](https://coveralls.io/r/kevinjalbert/git_statistics)
[![Code Climate](https://img.shields.io/codeclimate/github/kevinjalbert/git_statistics.svg)](https://codeclimate.com/github/kevinjalbert/git_statistics)
[![Dependency Status](https://img.shields.io/gemnasium/kevinjalbert/git_statistics.svg)](https://gemnasium.com/kevinjalbert/git_statistics)

## Instructions

### Using the gem
1. Acquire gem (`gem install git_statistics`)
2. Run `git statistics` in any directory that is a git repository (use -h for options)

### Working with source
1. Clone the repository
2. Install dependencies (`bundle install`)
3. Run tests `bundle exec rake`
4. Build and install local gem `bundle exec rake install`

## Functions

This gem will analyze every commit within a git repository using `git log` and [libgit2/rugged](https://github.com/libgit2/rugged). The following author statistics in relation to the git repository are collected and displayed:

* Total number of commits
* Total number of merge commits
* Total source line additions
* Total source line deletions
* Total file creates
* Total file deletes
* Total file renames
* Total file copies

This gem also uses [grosser/language_sniffer](https://github.com/grosser/language_sniffer) to determine the language of each individual file within commits. This augments the reported statistics by breaking down the author's statistics by languages.

This gem also has the ability to save the acquired data into a JSON file (in either a compressed or pretty format). If a saved file is present for the repository you can use the gem to load the data from the file, thus saving time for re-displaying the statistics using a different set of display flags (what statistic to sort on, number of authors to show, consider merges, etc...). In the event that a repository updates with new commits the gem allows you to update the saved file with the new commits.

## Example Output
The following is the output produced by `git_statistics --top 3` when used on the [pengwynn/octokit](https://github.com/pengwynn/octokit) (at commit [95a9de3](https://github.com/pengwynn/octokit/commit/95a9de325bee4ca03c9c1d61de2d643666c90037)) git repository. In this output we show the top three authors in rankings based on number of commits (merge commits are excluded from these results).

```
Top 3 authors(66) sorted by commits
-------------------------------------------------------------------------------------------------------------------
| Name/Email         | Language | Commits | Additions | Deletions | Creates | Deletes | Renames | Copies | Merges |
-------------------------------------------------------------------------------------------------------------------
| Erik Michaels-Ober |          |     205 |      6384 |      7692 |      78 |      43 |      69 |      2 |      0 |
|                    | Ruby     |       0 |      4223 |      3507 |      31 |       6 |      28 |      1 |      0 |
|                    | Unknown  |       0 |        81 |        70 |       6 |       3 |       1 |      0 |      0 |
|                    | Markdown |       0 |       379 |       336 |       3 |       2 |       1 |      0 |      0 |
|                    | JSON     |       0 |      1662 |      3735 |      38 |      31 |      39 |      1 |      0 |
|                    | YAML     |       0 |        39 |        44 |       0 |       1 |       0 |      0 |      0 |
| Wynn Netherland    |          |     185 |      8738 |     12925 |     155 |     107 |     115 |      1 |      0 |
|                    | Unknown  |       0 |       127 |        23 |     104 |      97 |       1 |      0 |      0 |
|                    | Ruby     |       0 |      3897 |      1825 |      21 |       4 |       1 |      0 |      0 |
|                    | JSON     |       0 |      4384 |     11012 |      29 |       6 |     112 |      0 |      0 |
|                    | Markdown |       0 |       325 |        65 |       1 |       0 |       1 |      0 |      0 |
|                    | YAML     |       0 |         5 |         0 |       0 |       0 |       0 |      1 |      0 |
| Clint Shryock      |          |     104 |      8038 |      3934 |      38 |      20 |       1 |      1 |      0 |
|                    | Ruby     |       0 |      1517 |       568 |       9 |       0 |       0 |      0 |      0 |
|                    | JSON     |       0 |      6519 |      3365 |      29 |      20 |       1 |      1 |      0 |
|                    | Markdown |       0 |         2 |         1 |       0 |       0 |       0 |      0 |      0 |
-------------------------------------------------------------------------------------------------------------------
| Repository Totals  |          |     720 |     75725 |     43567 |     387 |     183 |     189 |      9 |      0 |
|                    | Unknown  |       0 |       210 |        94 |     110 |     100 |       2 |      0 |      0 |
|                    | Ruby     |       0 |     15940 |      7861 |      81 |      13 |      32 |      2 |      0 |
|                    | JSON     |       0 |     58795 |     35157 |     191 |      67 |     153 |      6 |      0 |
|                    | Markdown |       0 |       730 |       411 |       4 |       2 |       2 |      0 |      0 |
|                    | YAML     |       0 |        50 |        44 |       1 |       1 |       0 |      1 |      0 |
```

