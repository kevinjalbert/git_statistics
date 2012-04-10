require 'ap'
require 'json'
require 'trollop'
require File.dirname(__FILE__) + '/commits.rb'

def collect(branch, since="")

  # Collect branches to use for git log
  branches = collect_branches
  branches = ["", ""] if branch

  pipe = open("|git --no-pager log #{branches.join(' ')} --date=iso --reverse"\
              " --no-color --numstat --summary #{since}"\
              " --format=\"%H,%an,%ae,%ad,%p\"")

  buffer = []
  pipe.each do |line|

    line = line.force_encoding("ISO-8859-1").encode("UTF-8")

    if line.split(',').size == 5  # Matches the number of ',' in the format
      extract_buffer(buffer) if not buffer.empty?
      buffer = []
    end

    buffer << line.strip
  end

  # Extract the last commit
  extract_buffer(buffer) if not buffer.empty?
end

def collect_branches

  pipe = open("|git --no-pager branch --no-color")

  branches = []
  pipe.each do |line|

    # Remove the '* ' leading the current branch
    line = line[1..-1] if line[0] == '*'
    branches << line.strip
  end

  return branches
end

def extract_buffer(buffer)

  commit_info = buffer[0].split(',')

  commit = (@commits[ commit_info[0] ] ||= Hash.new)
  commit[:author] = commit_info[1]
  commit[:author_email] = commit_info[2]
  commit[:time] = commit_info[3]
  commit[:insertions] = 0
  commit[:deletions] = 0
  commit[:creates] = 0
  commit[:deletes] = 0
  commit[:renames] = 0
  commit[:copies] = 0

  if commit_info[4] == nil or commit_info[4].split(' ').size == 1
    commit[:merge] = false
  else
    commit[:merge] = true
  end

  # Only extract diff details if they exist
  if buffer.size > 1

    buffer[2..-1].each do |line|

      next if extract_changes(commit, line)
      next if extract_create_delete_file(commit, line)
      next if extract_rename_copy_file(commit, line)

    end
  end
end

def extract_changes(commit, line)
  changes = line.scan( /(\d+)\s(\d+)\s(.*)/ )[0]

  if changes != nil and changes.size == 3
    commit[:insertions] += changes[0].to_i
    commit[:deletions] += changes[1].to_i
    return true
  end
end

def extract_create_delete_file(commit, line)
  changes = line.scan(/(create|delete) mode \d+ ([^\\\n]*)/)[0]

  if changes != nil and changes.size == 2
    commit[:creates] += 1 if changes[0] == "create"
    commit[:deletes] += 1 if changes[0] == "delete"
    return true
  end
end

def extract_rename_copy_file(commit, line)
  changes = line.scan(/(rename|copy)([^(]*)/)[0]

  if changes != nil and changes.size == 2
    commit[:renames] += 1 if changes[0] == "rename"
    commit[:copies] += 1 if changes[0] == "copy"
  end
  return true
end

def print_summary(sort_type, email, n=0)
  n = 0 if n < 0

  data = @commits.author_top_n_type(email, sort_type, n)

  if data == nil
    puts "ERROR: Parameter for --sort is not valid"
    return
  end

  # Find the longest name/email (used for string formatting)
  total_authors = @commits.author_list.length
  author_length = 17
  data.each do |key,value|
    author_length = key.length if key.length > author_length
  end

  # Print header information
  if n > 0 and n < total_authors
    puts "Top #{n} authors(#{total_authors}) sorted by #{sort_type.to_s}\n\n"
  else
    puts "All authors(#{total_authors}) sorted by #{sort_type.to_s}\n\n"
  end

  pattern = "%-#{author_length}s|%7s|%10s|%9s|%7s|%7s|%7s|%6s|%6s|"
  puts pattern % ['Name/email', 'commits', 'insertions', 'deletions', 'creates', 'deletes', 'renames', 'copies', 'merges']
  puts "-"*68 + "-"*author_length

  data.each do |key,value|
    puts pattern % [key, value[:commits], value[:insertions], value[:deletions],
         value[:creates], value[:deletes], value[:renames], value[:copies], value[:merges]]
  end

  puts "-"*68 + "-"*author_length
  puts pattern % ["Repository Totals", @commits.totals[:commits],
       @commits.totals[:insertions], @commits.totals[:deletions], @commits.totals[:creates],
       @commits.totals[:deletes], @commits.totals[:renames], @commits.totals[:copies], @commits.totals[:merges]]

end

@opts = Trollop::options do
  opt :email, "Use author's email instead of name", :default => false
  opt :merges, "Factor in merges when calculating statistics", :default => false
  opt :save, "Save the commits as commits.json", :default => false
  opt :load, "Load commits.json instead of re-collecting data", :default => false
  opt :update, "Update commits.json with new data (same as save and load together)", :default => false
  opt :sort, "Sort authors by {commits, insertions, deletions, creates, deletes, renames, copies, merges}", :default => "commits"
  opt :top, "Show the top N authors in results", :default => 0
  opt :branch, "Use current branch for statistics (otherwise all branches)", :default => false
end

# Collect commit data
if @opts[:load] || @opts[:update]
  @commits = Commits.new
  @commits.merge!(JSON.parse(File.read("commits.json"), :symbolize_names => true))
else
  @commits = Commits.new
  collect(@opts[:branch])
end

# Collect incremental recent data
if @opts[:update]
  collect(@opts[:branch], "--since=\"`date -r commits.json \"+%F %T\"`\"")
end

# Save data
if @opts[:save] || @opts[:update]
  File.open("commits.json", 'w') {|file| file.write(@commits.to_json)}
end

@commits.calculate_statistics(@opts[:email], @opts[:merges])

print_summary(@opts[:sort].to_sym, @opts[:top])
