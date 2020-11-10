class User < ActiveRecord::Base
    has_many :games
    has_many :spis, through: :games
    @@prompt = TTY::Prompt.new 
    
    def self.signup
        username = @@prompt.ask("What is your name?")
        password = @@prompt.mask("What is your password?")
        self.create(username: username, password: password)
    end

    def self.login
        username = @@prompt.ask("What is your name?")
        password = @@prompt.mask("What is your password?")
        self.find_by(username: username, password: password)
    end

    def high_scores
        self_new = Game.all.select{|g| g.user_id == self.id}
                final = self_new.map{|g| g.user_balance}
                    puts "High Score: $" + final[0].to_s
    end 
end