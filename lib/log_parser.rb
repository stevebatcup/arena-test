require File.expand_path('./core_ext/string.rb', File.dirname(__FILE__))
require File.expand_path('./file_not_found_exception.rb', File.dirname(__FILE__))

class LogParser
  attr_reader :file, :webpages

  def initialize(file)
    @file = file
    @webpages = []
  end

  def parse_file
    raise FileNotFoundException.new("Please specfiy a valid log file") if file.nil? || !File.exists?(file)

    parse_file_items.each do |log_item|
      next if log_item.nil?
      if existing_webpage = detect_existing_webpage(log_item)
        existing_webpage[:ips] << log_item[:ips].first
      else
        webpages << log_item
      end
    end
  end

  def parse_file_items
    File.open(file).read.each_line.map{ |line| parse_line(line) }
  end

  def parse_line(line)
    url = line.split[0]
    ip = line.split[1]
    { url: url, ips: [ip] } if url && ip && ip.is_valid_ipv4_address?
  end

  def detect_existing_webpage(log_item)
    webpages.detect { |webpage| webpage[:url] == log_item[:url] }
  end

  def webpages_with_view_counts(unique=false)
    list = webpages.map do |page|
      {
       url: page[:url],
       count: unique ? page[:ips].uniq.length : page[:ips].length
      }
    end
    list.sort_by{ |item| item[:count] }.reverse
  end

  def list_page_views
    webpages_with_view_counts(false).map { |page|"#{page[:url]} #{"visit".pluralise(page[:count])}" }
  end

  def list_unique_page_views
    webpages_with_view_counts(true).map { |page|"#{page[:url]} #{"unique view".pluralise(page[:count])}" }
  end
end