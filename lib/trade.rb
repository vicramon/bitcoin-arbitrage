require 'btce'

class Trade
  attr_accessor :api, :path

  def initialize(*args)
    self.path = *args
    self.api =  Btce::TradeAPI.new_from_keyfile
  end

  def trade
    puts 'made a trade'

    # (path.length -1 ).times do |i|

    #   start = path[i]
    #   finish = path[i+1]

    #   params = {
    #     pair: "#{start}_#{finish}",
    #     type: "sell",
    #     rate: # get rate,
    #     amount: # choose amount
    #   }
    #   api.trade_api_call("?", params)
    # end
  end

end
