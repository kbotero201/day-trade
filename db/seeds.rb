require 'pry'
require 'rest-client' # in order to make HTTP requests from a ruby file
require 'json'

Spi.destroy_all
User.destroy_all
Game.destroy_all

price_api_resp = RestClient.get("https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=IBM&interval=60min&outputsize=full&apikey=VLBVHKO2VWRJNR1W")
price_api_data =JSON.parse(price_api_resp)

macd_api_resp = RestClient.get("https://www.alphavantage.co/query?function=RSI&symbol=IBM&interval=60min&time_period=14&series_type=open&apikey=VLBVHKO2VWRJNR1W")
macd_api_data =JSON.parse(macd_api_resp)

rsi_api_resp = RestClient.get("https://www.alphavantage.co/query?function=MACD&symbol=IBM&interval=60min&series_type=open&apikey=VLBVHKO2VWRJNR1W")
rsi_api_data = JSON.parse(rsi_api_resp)





Spi.create(stock_symbol: price_api_data["Meta Data"]["2. Symbol"])

User.create(username: "Caryn", password: "12345")
