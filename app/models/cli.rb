require "tty-prompt"
require "pry"
require 'rest-client'  
require 'json' 



class CLI
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
        # sleep(1.5)
        @@user = User.first
        self.display_menu
        # choices = { "Log In" => 1,
        #     "Sign Up" => 2
        # }
        # choice = @@prompt.select("Would you like to sign up or log in?", choices)
        # if choice == 1
        #     @@user = User.login
        #     if @@user
        #         self.display_menu
        #     else
        #         self.auth_sequence
        #     end
        # else
        #     @@user = User.signup
        #     if @@user
        #         self.display_menu
        #     else
        #         self.auth_sequence
        #     end
        # end
    end

    def random_symbol
        stock_symbols= ["GOOG", "IBM", "SPY"]
        stock_symbols.sample
        price_api_resp = RestClient.get("https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{stock_symbols.sample}&interval=60min&outputsize=full&apikey=VLBVHKO2VWRJNR1W")
        price_api_data =JSON.parse(price_api_resp)
        Spi.create(stock_symbol: price_api_data["Meta Data"]["2. Symbol"])
    end


    def display_menu
    

        choices = { "Start game" => 1,
                    "Test" => 2
        }
        action = @@prompt.select("What would you like to do?", choices)
        case action
            when 1
                new1 = self.random_symbol
                 macd_api_resp = RestClient.get("https://www.alphavantage.co/query?function=MACD&symbol=#{new1.stock_symbol}&interval=60min&series_type=open&apikey=VLBVHKO2VWRJNR1W")
                macd_api_data = JSON.parse(macd_api_resp)
                @@game = Game.new
                @@game.user_balance = 100000
                @@game.date = macd_api_data["Technical Analysis: MACD"].to_a.sample[0].split(" ")[0]
                puts "Hi, #{@@user.username}, your balance is #{@@game.user_balance} "
                puts "For this game, your stock is: #{new1.stock_symbol}"
                puts "Your startdate is #{@@game.date}"
            
        end
                
        # # Displays the options to the user!
        # system('clear')
        # choices = { "Play a random category" => 1,
        #         "Search for a category" => 2, 
        #         "See my game results" => 3,
        #         "See leaderboard" => 4,
        #         "Select from all categories" => 5
        #     }
        # action = @@prompt.select("What would you like to do?", choices)
        # case action
        # when 1 
        #     random_cat = Category.all.sample # gets random category from those seeded
        #     api_data = self.get_category_data(random_cat) # uses helper method to get clues from API
        #     self.play_game(random_cat.id, api_data) # plays the game!
        # when 2
        #     puts "You chose to search"
        # when 3
        #     puts "You chose to see results"
        # when 4
        #     puts "You chose to see your game results"
        # when 5
        #     chosen_category = self.choose_category # uses helper method to display and get category choice
        #     api_data = self.get_category_data(chosen_category) # uses helper method to get clues from API
        #     self.play_game(chosen_category.id, api_data) # plays the game!
        # end
    end
end
    