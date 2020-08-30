require File.expand_path('../lib/log_parser.rb', File.dirname(__FILE__))

RSpec.describe LogParser do
  let(:file) { File.expand_path('./test_webserver.log', File.dirname(__FILE__)) }
  let(:parser) { parser = LogParser.new(file) }

  it 'holds onto the file path' do
    simple_parser = LogParser.new('foo.log')
    expect(simple_parser.file).to eq('foo.log')
  end

  it 'throws a FileNotFoundException if given file path is not an actual file' do
    bad_file_parser = LogParser.new('foo.log')
    expect{ bad_file_parser.parse_file }.to raise_exception(FileNotFoundException)
  end

  it 'parses an example log line into a url and an ip list' do
    parsed_line = parser.parse_line('/products/2 228.32.104.207')
    expect(parsed_line[:url]).to eq('/products/2')
    expect(parsed_line[:ips]).to eq(['228.32.104.207'])
  end

  it 'parses each line from the file into a url and an ip list' do
    items = parser.parse_file_items
    expect(items.length).to eq(14) # 14 total lines in the file
    expect(items.first[:url]).to eq('/products/2')
    expect(items.first[:ips].length).to eq(1)
    expect(items.first[:ips]).to eq(['61.64.28.106'])
  end

  it 'parses each valid line of the log file into the webpages collection' do
    parser.parse_file
    expect(parser.webpages.length).to eq(5) # 5 unique valid URLs in the file
    expect(parser.webpages.first[:url]).to eq('/products/2')
    expect(parser.webpages.first[:ips].length).to eq(4)
  end

  it 'does not add an invalid line into the webpages collection' do
    parser.parse_file
    expect(parser.webpages).to_not include({:url=>nil, :ips=>[nil]}) # the blank line
    expect(parser.webpages).to_not include({:url=>nil, :ips=>['1.1.1.1']}) # the erroneous url line
    expect(parser.webpages).to_not include({:url=>"/foo", :ips=>[nil]}) # the erroneous ip line
  end

  it 'generates a collection of webpages ordered by most overall visits' do
    parser.parse_file
    views = parser.webpages_with_view_counts
    expect(views.first[:url]).to eq('/products/2')
    expect(views.first[:count]).to eq(4) # 4 overall visits to this URL
    expect(views.last[:url]).to eq('/contact')
    expect(views.last[:count]).to eq(1)
  end

  it 'generates a collection of webpages ordered by most unique views' do
    parser.parse_file
    unique_views = parser.webpages_with_view_counts(true)
    expect(unique_views.first[:url]).to eq('/products/2')
    expect(unique_views.first[:count]).to eq(3) # 3 unique visits to this URL
    expect(unique_views.last[:url]).to eq('/contact')
    expect(unique_views.last[:count]).to eq(1)
  end

  it 'outputs a list of webpage views' do
    parser.parse_file
    views = parser.list_page_views
    expect(views).to include('/contact 1 visit')
    expect(views).to include('/products/2 4 visits')
  end

  it 'outputs a list of unique webpage views' do
    parser.parse_file
    unique_views = parser.list_unique_page_views
    expect(unique_views).to include('/contact 1 unique view')
    expect(unique_views).to include('/products/2 3 unique views')
  end
end