require 'ap'
require 'json'
require 'trollop'
require File.dirname(__FILE__) + '/commits.rb'

def collect(since="")

  branches = collect_branches

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
    commit[:insertions] = changes[0].to_i
    commit[:deletions] = changes[1].to_i
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

@opts = Trollop::options do
  opt :email, "Use author's email instead of name", :default => false
  opt :save, "Save the commits as commits.json", :default => false
  opt :load, "Load commits.json instead of re-collecting data", :default => false
  opt :update, "Update commits.json with new data (same as save and load together)", :default => false
end

# Collect commit data
if @opts[:load] || @opts[:update]
  @commits = Commits.new
  @commits.merge!(JSON.parse(File.read("commits.json"), :symbolize_names => true))
else
  @commits = Commits.new
  collect
end

# Collect incremental recent data
if @opts[:update]
  collect("--since=\"`date -r commits.json \"+%F %T\"`\"")
end

# Save data
if @opts[:save] || @opts[:update]
  File.open("commits.json", 'w') {|file| file.write(@commits.to_json)}
end

@commits.calculate_statistics(@opts[:email])

ap "Top Author - Commits"
ap @commits.author_top_n_type(@opts[:email], :commits, 1)
