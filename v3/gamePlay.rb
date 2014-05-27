#Shreyas Kumar
#LiveRamp BlackJack programming challenge


#import blackjackClasses.rb for class definitions
require_relative 'blackjackClasses'

#script starts here. class definitions in LiveRamp.rb, 
#other functions that are called are defined above

#instantiate game object; create players and build deck
game = Game.new
game.play()