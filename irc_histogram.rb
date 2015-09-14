require 'restclient'

require_relative 'ngrams'

class LogParser
  LOG_DIR  = 'irc_logs'

  def initialize(date, channel = "ruby")
    @date = date
    @channel  = channel
    @log_name = "#{LOG_DIR}/#{@channel}/irc-log-#{@date}.txt"
  end

  def download_page(url)
    return log_contents if File.exist? @log_name
    RestClient.get(url).body
  end

  def save_page(page)
    File.open(@log_name, "w+") { |f| f.puts page }
  end

  def log_contents
    File.readlines(@log_name).join
  end

  def get_messages
    page = download_page("http://irclog.whitequark.org/#{@channel}/#{@date}.txt")
    save_page(page)
    page
  end
end

def filter_non_words(ngrams)
  ngrams.reject { |w1, w2| w1 !~ /^\w+/ || w2 !~ /^\w+/ }
end

CHAT_MESSAGE   = /(\d+-\d+-\d+) (\d+:\d+) (<\w+>) ([\w ]+)/
STATUS_MESSAGE = /(\d+-\d+-\d+) (\d+:\d+) ([\w ]+)/

def get_trigrams_for_date(date)
  irc = LogParser.new(date)
  msg = irc.get_messages.split("\n").select { |m| m.match(CHAT_MESSAGE) }.join

  ngrams  = Ngram.new(msg).ngrams(3)
  ngrams  = filter_non_words(ngrams)
  bigrams = ngrams.map{ |n| n.join(' ') }

  bigrams.each_with_object(Hash.new(0)) { |word, obj| obj[word.downcase] += 1 }
end

MIN_REPETITIONS = 20

if __FILE__ == $PROGRAM_NAME
  total = {}

  (1..15).each do |n|
    zero_padded = '%02d' % [n]
    total.merge!(get_trigrams_for_date "2015-04-#{zero_padded}") { |k, old, new| old + new }
  end

  total = total.sort_by { |k, v| -v }.reject { |k, v| v < MIN_REPETITIONS }
  total.each { |k, v| puts "#{v} => #{k}" }
end
