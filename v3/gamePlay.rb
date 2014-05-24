#Shreyas Kumar
#LiveRamp BlackJack programming challenge


#import blackjackClasses.rb for class definitions
require_relative 'blackjackClasses'



#script starts here. class definitions in LiveRamp.rb, 
#other functions that are called are defined above

game = Game.new

while game.getNumPlayers() > 1
	#deal cards and update the player list and deck
	game.placeBets()
	#necessary because ruby does not use pass by reference
	game.initialDeal()
	#all players + dealer play
	game.playEntireTurn()
	game.scoreTurn()
	#option to opt out
	bool = game.check()
	if bool
		break
	end
end
#ending messages
game.end()