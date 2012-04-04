def collect

  branches = collect_branches

  pipe = open("|git --no-pager log #{branches.join(' ')} --date=iso --reverse"\
              " --no-color --numstat --summary --format=\"%H,%an,%ad,%p\"")

  buffer = []
  pipe.each do |line|

    if line.split(',').size == 4
      extract_buffer(buffer) if not buffer.empty?
      buffer = []
    end

    buffer << line.strip

  end
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

  @commits += 1

  commit_info = buffer[0].split(',')
  puts "sha: #{commit_info[0]}"
  puts "author: #{commit_info[1]}"
  puts "time: #{commit_info[2]}"

  if commit_info[3] == nil or commit_info[3].split(' ').size == 1
    puts "merge: false"
  else
    @merges += 1
    puts "merge: true"
  end

  puts ""
end


@commits = 0
@merges = 0

collect

puts "commits: #{@commits}"
puts "merges: #{@merges}"