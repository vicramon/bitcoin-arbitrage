require_relative 'rate_fetcher'
require_relative 'trade'

class Arbitrage

  attr_accessor :path, :starting_amount, :number_of_trades, :fee

  def initialize(*args)
    self.path = *args
    self.starting_amount = 1.0
    self.number_of_trades = path.length - 1
    self.fee = 0.002
  end

  def calculate
    amount = starting_amount
    number_of_trades.times do |i|
      start = path[i]
      finish = path[i+1]
      rate = RateFetcher.new(start, finish).rate
      amount *= rate
      amount -= amount * fee
    end
    1 - amount
  end

  def run
    new_amount = calculate
    new_amount = 0 if new_amount == 1
    new_amount
  end

end

