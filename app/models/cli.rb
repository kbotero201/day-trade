require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 



class CLI
    def price=(price)
        @price=price
    end

    def price
        @price
    end
    @@prompt = TTY::Prompt.new
    @@artii = Artii::Base.new :font => 'slant'
    @@user = nil

    def welcome
        system('clear')
        puts @@artii.asciify("Welcome to")
        puts @@artii.asciify("Day Trading Game!!!")
        self.auth_sequence
    end

    def auth_sequence
        sleep(1.5)
        
        choices = { "Log In" => 1,
            "Sign Up" => 2
        }
        choice = @@prompt.select("Would you like to sign up or log in?", choices)
        if choice == 1
            @@user = User.login
            if @@user
                self.display_menu
            else
                self.auth_sequence
            end
        else
            @@user = User.signup
            if @@user
                self.display_menu
            else
                self.auth_sequence
            end
        end
    end

    def random_symbol
        stock_symbols= ["GOOG", "IBM", "SPY"]
        stock_symbols.sample
        price_api_resp = RestClient.get("https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{stock_symbols.sample}&interval=60min&outputsize=full&apikey=M0HFRMUEXY3UAOWU")
        price_api_data =JSON.parse(price_api_resp)
        @@spi = Spi.new(stock_symbol: price_api_data["Meta Data"]["2. Symbol"])
    end

    def stock_price(stock_name, date, time)
        price_api_resp = RestClient.get("https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{stock_name}&interval=60min&outputsize=full&apikey=M0HFRMUEXY3UAOWU")
        price_api_data =JSON.parse(price_api_resp)
        price_api_data["Time Series (60min)"]["#{date} #{time}"]["1. open"]
    end

    def rsi(stock_name, date, time)
       rsi_api_resp = RestClient.get("https://www.alphavantage.co/query?function=RSI&symbol=#{stock_name}&interval=60min&time_period=14&series_type=open&apikey=M0HFRMUEXY3UAOWU")
       rsi_api_data =JSON.parse(rsi_api_resp)
       rsi_api_data["Technical Analysis: RSI"]["#{date} #{time}"]["RSI"]
    end 

    def macd(stock_name, date, time)
        macd_api_resp = RestClient.get("https://www.alphavantage.co/query?function=MACD&symbol=#{stock_name}&interval=60min&series_type=open&apikey=M0HFRMUEXY3UAOWU")
        macd_api_data = JSON.parse(macd_api_resp)
        macd_api_data["Technical Analysis: MACD"]["#{date} #{time}"]["MACD"]
    end

    def tenam_3pm_hours(time)
         puts
        ##{time}.am info
        @price = (self.stock_price(@new1.stock_symbol, @@game.date, "#{time}:00:00")).to_f.round(2)
        @total_shares_value = @shares * @price
        @net_liquidating_value = (@total_shares_value + @@game.user_balance).round(2)
        @daily_gain_loss = ((@net_liquidating_value - 100000) / 100000 * 100).round(3)
        puts "The stock price at #{time}:00 is $#{@price}"
           if @net_liquidating_value < 100000
                puts "Your net liquidating value is $#{@net_liquidating_value}, a #{@daily_gain_loss}% decrease! :("
            elsif @net_liquidating_value > 100000
                puts "Your net liquidating value is $#{@net_liquidating_value}, a #{@daily_gain_loss}% increase! :)"
            else
                puts "Your net liquidating value is $#{@net_liquidating_value}"
            end
        puts "Your current balance is $#{@@game.user_balance.round(2)}"
        puts "Your total #{@new1.stock_symbol} share count is #{@shares}"
        puts "The RSI is #{self.rsi(@new1.stock_symbol, @@game.date, "#{time}:00")}, and the MACD is #{self.macd(@new1.stock_symbol, @@game.date, "#{time}:00")}"
        

        ##{time}a.m choices
        if @shares == nil
             choices = {"Buy Stocks" => 1,
                        "Hold and wait to see price at next hour" => 2
                    }
            action = @@prompt.select("What would you like to do?", choices)
        elsif @@game.user_balance < @price 
            choices = {"Hold and wait to see price at next hour" => 2,
                       "Sell stocks"  => 3
                    }
            action = @@prompt.select("What would you like to do?", choices)   
        else
            choices = {"Buy Stocks" => 1,
                      "Hold and wait to see price at next hour" => 2,
                      "Sell stocks"  => 3
                    }
            action = @@prompt.select("What would you like to do?", choices)
        end

        case action 

            when 1 
                    choices = {"Choose how many shares you would like to buy" => 1,
                               "Buy maximum amount of shares with money available" => 2
                        }
                    action = @@prompt.select("What would you like to do?", choices)
                case action
                    when 1
                    
                        choice = gets.chomp.to_i
                        @total = (choice * @price).round(2)
                        @maximum_shares = (@@game.user_balance / @price).to_i
                            if choice >= @maximum_shares
                                puts "You don't have enough money!!"
                                puts "You can buy a maximum of #{@maximum_shares} shares!"
                                puts "Please enter a valid share amount!"
                                choice = gets.chomp.to_i
                                @total = (choice * @price).round(2)
                            end
                        puts "You've purchased #{choice} shares at $#{@price} a share for a total of $#{@total}!" 
                        @@game.user_balance -= @total 
                        @shares += choice
                        puts "Your available funds for trading is now $#{@@game.user_balance.round(2)}!"

                    when 2
                        @maximum_shares = (@@game.user_balance / @price).to_i
                        @total = (@maximum_shares * @price).round(2)
                        puts "You've bought maximum amount of shares for a total of $#{@total}!" 
                        @@game.user_balance -= @total 
                        @shares += @maximum_shares
                        puts "Your available funds for trading is now $#{@@game.user_balance.round(2)}!"
                end
            
            when 2
            

            
            when 3
                    puts "How many shares would you like to sell?"
                    choice = gets.chomp.to_i
                    @total = (choice * @price).round(2)
                    @maximum_shares = (@@game.user_balance / @price).to_i
                        if choice > @shares
                            puts "You don't have enough shares!!"
                            puts "You can sell a maximum of #{@shares} shares!"
                            puts "Please enter a valid share amount to sell!"
                            choice = gets.chomp.to_i
                            @total = (choice * @price).round(2)
                        end
                puts "You've sold #{choice} shares at $#{@price} a share for a total of $#{@total}!" 
                @@game.user_balance += @total 
                @shares -= choice
                puts "Your available funds for trading is now $#{@@game.user_balance.round(2)}!"
        end
    end

   





    #START GAME 
    
    def display_menu
    
        #start menu, 9a.m info
        choices = { "Start game" => 1,
                    "Take the tutorial" => 2,
                    "Check all time leaderboards" => 3,
                    "Check your high scores" => 4
        }
        action = @@prompt.select("What would you like to do?", choices)
        case action
            when 1
                system("clear")
                @new1 = self.random_symbol
                 macd_api_resp = RestClient.get("https://www.alphavantage.co/query?function=MACD&symbol=#{@new1.stock_symbol}&interval=60min&series_type=open&apikey=M0HFRMUEXY3UAOWU")
                macd_api_data = JSON.parse(macd_api_resp)
                @@game = Game.new
                @@game.user_balance = 100000
                @@game.date = macd_api_data["Technical Analysis: MACD"].to_a.sample[0].split(" ")[0]
                puts "Hi, #{@@user.username}, your balance is $#{@@game.user_balance} "
                puts "For this game, your stock is: #{@new1.stock_symbol}"
                puts "Your startdate is #{@@game.date}"
                @price = (self.stock_price(@new1.stock_symbol, @@game.date, "09:00:00")).to_f.round(2)
                puts "The stock price at 9am is $#{price}"
                puts "The RSI is #{self.rsi(@new1.stock_symbol, @@game.date, "09:00")}, and the MACD is #{self.macd(@new1.stock_symbol, @@game.date, "09:00")}"
                choices = {"Buy Stocks" => 1,
                           "Hold and wait to see price at next hour" => 2
                }
                action = @@prompt.select("What would you like to do?", choices)
                
                #9a.m choices
                case action 

                    when 1 
                        choices = {"Choose how many shares you would like to buy" => 1,
                                "Buy maximum amount of shares with money available" => 2
                            }
                        action = @@prompt.select("What would you like to do?", choices)
                        case action
                            when 1
                                @shares = 0
                                choice = gets.chomp.to_i
                                @total = (choice * @price).round(2)
                                @maximum_shares = (@@game.user_balance / @price).to_i
                                    if choice >= @maximum_shares
                                        puts "You don't have enough money!!"
                                        puts "You can buy a maximum of #{@maximum_shares} shares!"
                                        puts "Please enter a valid share amount!"
                                        choice = gets.chomp.to_i
                                        @total = (choice * @price).round(2)
                                    end
                                puts "You've purchased #{choice} shares at $#{@price} a share for a total of $#{@total}!" 
                                @@game.user_balance -= @total 
                                @shares += choice
                                puts "Your available funds for trading is now $#{@@game.user_balance.round(2)}!"

                            when 2
                                @shares = 0
                                @maximum_shares = (@@game.user_balance / @price).to_i
                                @total = (@maximum_shares * @price).round(2)
                                puts "You've bought maximum amount of shares for a total of $#{@total}!" 
                                @@game.user_balance -= @total 
                                @shares += @maximum_shares
                                puts "Your available funds for trading is now $#{@@game.user_balance.round(2)}!"
                        end
                    when 2
                        @shares = 0
                end
            when 2
                puts
                puts "Welcometo Day Trading Game!" 
                puts "Let's learn about Day Trading and what indicators & stocks are."
                puts 
                puts "You get to either BUY, HOLD, or SELL."
                puts "Make sure to use the helpful RSI and MACD information to make trading decisions"
                puts
                puts "What is an RSI?"
                puts "The cheat sheet? If the RSI is under 30 that means the stock is oversold."
                puts "If it's over 70 that means the stock is overbought"
                puts "Learn more about RSI here: https://www.investopedia.com/terms/r/rsi.asp"
                puts
                puts "What's a MACD?"
                puts "The MACD cheat sheet? If the number is over 0, that confirms an upwards trend"
                puts "If it's lower than 0, that confirms a downwards trend"
                puts "Learn more about MACD here: https://www.investopedia.com/terms/m/macd.asp"

                self.display_menu
        

            when 3
                new = Game.all.map{|g| g.user_balance}.max(10)
                puts "1) $" + new[0].to_s
                puts "2) $" + new[1].to_s
                puts "3) $" + new[2].to_s
                puts "4) $" + new[3].to_s
                puts "5) $" + new[4].to_s
                puts "6) $" + new[5].to_s
                puts "7) $" + new[6].to_s
                puts "8) $" + new[7].to_s
                puts "9) $" + new[8].to_s
                puts "10) $" + new[9].to_s
                
                self.display_menu
                
            when 4
                @@user.high_scores
                self.display_menu
        end
        
        self.tenam_3pm_hours(10)
        self.tenam_3pm_hours(11)
        self.tenam_3pm_hours(12)
        self.tenam_3pm_hours(13)
        self.tenam_3pm_hours(14)
        self.tenam_3pm_hours(15)

        @@spi.save
        @@game.user_balance = @net_liquidating_value
        @@game.user_id = @@user.id
        @@game.spi_id = @@spi.id
        @@game.save 
        
        puts
        puts 
        puts "It is now 4p.m, the stock market is now closed!"
        puts "You've ended the day with a total amount of $#{@net_liquidating_value}!!"
    end
end
    

