#Shreyas Kumar
#LiveRamp BlackJack programming challenge


#import blackjackClasses.rb for class definitions
require_relative 'blackjackClasses'

#script starts here. class definitions in LiveRamp.rb, 
#other functions that are called are defined above

#instantiate game object; create players and build deck
game = Game.new

while game.getNumPlayers() > 1
	#invite bets from players
	game.placeBets()
	#deal out a pair of cards to players and dealer
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