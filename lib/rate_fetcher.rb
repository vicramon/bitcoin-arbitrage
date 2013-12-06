class RateFetcher
  require 'btce'

  attr_accessor :start, :finish, :pair, :pair_for_api
  # ltc_usd, btc_usd, ltc_btc
  def initialize(start, finish)
    self.start = start
    self.finish = finish
    self.pair = "#{start}_#{finish}"
    setup_pair_for_api
  end

  def setup_pair_for_api
    if pair_exists?
      self.pair_for_api = pair
    else
      self.pair_for_api = inverted_pair
    end
  end

  def get_data
    begin
      data = Btce::Ticker.new(pair_for_api).json.fetch("ticker")
    rescue
      puts 'Error: bad pair'
      puts pair_for_api
    end
  end

  def rate
    data = get_data
    if pair_exists?
      data.fetch("buy")
    else
      1 / data.fetch("sell")
    end
  end

  def pair_exists?
    Btce::API::CURRENCY_PAIRS.include?(pair)
  end

  def inverted_pair
    "#{finish}_#{start}"
  end

end

puts RateFetcher.new(:usd, :btc).rate
