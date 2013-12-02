require "bundler"
Bundler.require

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO
LOGGER.formatter = ->(*args, msg){ "#{msg}\n" }
ENV["REDIS_URL"] = ENV["REDISTOGO_URL"] if ENV["REDISTOGO_URL"]
REDIS = Redis.new
FEE = 0.2

# track exchange rates
def track_rates
  %w[ltc_usd btc_usd ltc_btc].map do |rate|
    Thread.new do
      loop do
        begin
          data = Btce::Ticker.new(rate).json.fetch("ticker")
          REDIS.setex rate, 1, Marshal.dump(data)
          REDIS.incr "#{rate}_success"
          LOGGER.debug "Got rate for #{rate}: #{data.inspect}"
          sleep 0.5
        rescue => e
          REDIS.incr "#{rate}_failure"
          REDIS.set "#{rate}_last_error", e.inspect
          LOGGER.warn "Error fetching rates: #{e.inspect}"
        end
      end
    end
  end
end

def f(a)
  "%.3f" % a
end

# track arbitrage
class Arbitrage
  def initialize(path)
    @path = path
  end

  def result(amount = 1.0)
    initial_amount = amount

    @_log = f(amount) + convertions.first.first
    convertions.each do |from, to|
      key = [from,to].join("_").downcase
      invert = !Btce::API::CURRENCY_PAIRS.include?(key)
      key = [to,from].join("_").downcase if invert
      data = Marshal.load(REDIS.get(key))
      rate = invert ? 1/data.fetch("sell") : data.fetch("buy")

      amount *= rate
      amount *= (100 - FEE)/100

      @_log << " => #{f(amount)}#{to}"
    end

    amount
  rescue TypeError
    0
  end

  def anounce!
    value = result(1.0)

    if value > 1
      profit = value * 100 - 100
      @_log << " (#{f(profit)}% Profit)"
      LOGGER.info @_log
    end
  end

  def convertions
    currencies.zip(shifted_currencies)
  end

  def currencies
    @currencies ||= @path.scan(/[A-Z]{3}/)
  end

  def shifted_currencies
    currencies.clone.tap{ |c| c.push c.shift }
  end
end

track_rates

path_a = Arbitrage.new("LTC->BTC->USD")
path_b = Arbitrage.new("LTC->USD->BTC")

loop do
  path_a.anounce!
  path_b.anounce!
  sleep 1
end
