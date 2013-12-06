require_relative 'rate_fetcher'
require_relative 'trade'
require_relative 'arbitrage'
require 'btce'

class Runner

  PATHS = [
    [:ltc, :btc, :usd, :ltc],
    [:btc, :ltc, :usd, :btc]
  ]

  def run
    loop do
      PATHS.each do |path|
        profit = Arbitrage.new(*path).run
        output(path, profit)
        Trade.new(*path).trade if profit > 0

        sleep 1
      end
    end
  end

  def output(path, profit)
    puts path.to_s + " " + (profit * 100).to_s + "%"
  end

end

Runner.new.run
