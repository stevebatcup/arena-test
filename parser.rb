# Test subsmission for Arena by Steve Batcup

# Please note: I made a few adjustments to the webserver.log file so as to produce more obvious results
# - added a few blank lines
# - added invalid rows (missing url or ip address)
# - added and removed a few items so as to avoid all unique view counts resulting in 20, thus they can be more explicitly ordered

# Built using local Ruby v2.7.0 and RSpec 3.9

require File.expand_path('./lib/log_parser.rb', File.dirname(__FILE__))

puts "### Running script ###"
parser = LogParser.new(ARGV[0])

parser.parse_file

puts "# Webpage views..."
parser.list_page_views.each { |view| puts "- #{view}" }

puts "# Webpage unique views..."
parser.list_unique_page_views.each { |view| puts "- #{view}" }

puts "### All done 😃 ###"