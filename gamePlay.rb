#Shreyas Kumar
#LiveRamp BlackJack programming challenge


#import blackjackClasses.rb for class definitions
require_relative 'blackjackClasses'


def buildDeck()
	#Build the deck, required for any game
	deck = Array.new()
	#cycle through all possible cards
	#4 deck shoe
	for k in 1..4
		for i in ['Spades', 'Hearts', 'Diamonds', 'Clubs']
			for j in [2,3,4,5,6,7,8,9,10, 'J', 'Q', 'K',  'A']
				deck.push(Card.new(i, j))
			end
		end
	end
	return deck
end

def createPlayers()
	#Creates a user specified number of players
	playerList = Array.new
    playerList.push(Player.new('Player 1'))
	puts "Created Player 1."
	#user determines how many players are necessary. The implementation could use less user input
	#for example, only take in how many players are playing in the beginning
	while true
		puts "Do you want to add another player? y/n"
		answer = gets
		#create the list of players
		if answer.chomp == "y" #chomp gets rid of the newline character
			playerList.push(Player.new('Player ' + (playerList.count+1).to_s))
			puts "Created Player #{playerList.count}"
		else
			break
		end
	end
	puts "We have #{playerList.count} players at the table."
	return playerList
end

def dealCard(deck)
	#deal a random card
	cardToDeal = deck.sample() #change to choice for ruby1.8.7
	return cardToDeal
end

def initialDeal(deck, playerList)
	#the first set of cards are dealt (two cards to each player including the dealer)
	j = 0
	while j < 2 do 
		for i in playerList
			cardToDeal = dealCard(deck)
			i.addCard(cardToDeal, 0)
			deck.delete(cardToDeal) #make sure we stay true to the game: you can still count cards!
			#puts "Deck Count is #{deck.count}"
		end
		j += 1
	end
	return [deck, playerList]
end

def placeBets(playerList)
	#method that allows each player to place bets. Bets can only be integers, and have to be less than their pot.
	for i in 0..playerList.count - 2 #cycle through all players except for the dealer (dealer is the last element of playerList)
		while true 
			puts "#{playerList[i].getName()}, place your bet. You're pot is #{playerList[i].getPot()}."
			bet = gets
			if !(bet.chomp.class == Fixnum)
				"This game only accepts integer bets"
			end
			if bet.chomp.to_i < playerList[i].getPot()
				playerList[i].setBet(0, bet.chomp.to_i) #sets the bet as specified
				break
			else
				puts "You're pot is not big enough to support that bet."
			end
		end
	end
	return playerList
end

def hit(player, deck, numHand = 0)
	#method that allows a player/dealer to hit
	cardToDeal = dealCard(deck)
	player.addCard(cardToDeal, numHand) #add card to the hand
	deck.delete(cardToDeal) #delete the drawn card from the deck
	puts "#{player.getName()} has been dealt #{cardToDeal.getName()} of #{cardToDeal.getSuit()}"
	return deck
end

def split(player, numHand)
	#set up split hands.
	hand = player.getHand(numHand)
	player.addHand(hand[1]) #create the split hand
	player.popCard(numHand) #remove the extra card in the original hand
	return player
end

def playSingleTurn(player, deck, numHand = 0)
	#plays the turn of one player
	puts "#{player.getName()}'s turn, hand #{numHand}."

	#in case this is a split hand with just one card, draw the second card
	hand = player.getHand(numHand)
	if hand.count == 1
		deck = hit(player, deck, numHand)
	end

	#print out the hand values and the handfor player convenience
	if player.getValue()[1] != nil
		puts "#{player.getName()} is at #{player.getValue()[0]} with A at 11 or at #{player.getValue()[1]} with A at 1"
	else
		puts "#{player.getName()} is at #{player.getValue()[0]}"
	end
	player.printHand(numHand)
	
	#check for blackjack on initial deal
	if player.getValue()[0] == 21
		puts "You have hit blackjack! Now wait for the dealer's turn to decide winnings."
		return [deck, player]
	end

	#ask the user if he/she wants to split. Checks to make sure both cards are the same, there are only two cards, and the player can afford the second bet in the split
	if hand.count == 2 && hand[0].getCardValue() == hand[1].getCardValue() && ((player.totalBet() + player.getBet(numHand)) < player.getPot()) 
		puts "Do you want to split? y/n"
		answerSplit = gets
		if answerSplit.chomp == 'y'
			player = split(player, numHand)
			return [deck, player, true]
		end
	end

	#check if the user wants to double down. Again, only possible if player has enough money
	if (player.totalBet() + player.getBet(numHand)) < player.getPot()
		puts "Do you wish to double down? y/n"
		answer = gets
		if answer.chomp == 'y'
			player.setBet(2*player.getBet(numHand)) #change the bet to double the initial
		end
	end
	flag = false #to print the hand in the while loop
	while true
		if flag
			#prints out the hand value and hand for user convenience as the user hits
			if player.getValue()[1] != nil
				puts "#{player.getName()} is at #{player.getValue()[0]} with A at 11 or at #{player.getValue()[1]} with A at 1"
			else
				puts "#{player.getName()} is at #{player.getValue()[0]}"
			end
			player.printHand(numHand)
		end
		flag = true
		puts "Do you want to hit or stay? h/s"
		answer = gets
		#is user hits
		if answer.chomp == 'h'
			deck = hit(player, deck, numHand)
			#if the player busts, change the pot, reset the bet
			if player.getValue(numHand)[0] > 21
				puts "#{player.getName()} has busted with hand #{numHand + 1}. You lose your bet of #{player.getBet()}."
				player.setPot(player.getPot() - player.getBet(numHand))
				player.setBet(numHand, 0)
				puts "Your pot is now #{player.getPot()}."
				#check if the player has lost all his/her money. 
				if player.getPot() == 0
					puts "You have no money left, you have lost."
					break
				end
				break
			#player at blackjack
			elsif player.getValue(numHand)[0] == 21
				puts "You have hit blackjack! Now wait for the dealer's turn to decide winnings."
				break
			end
		#player stays
		elsif answer.chomp == 's'
			puts "You chose to stay. Your hand's value is #{player.getValue()[0]}. Now wait for the dealer's turn to decide winnings."
			break
		else
			puts "Invalid response. h for Hit, s for Stay."
		end
	end
	return [deck, player]
end

def playTurnDealer(dealer, deck)
	#dealer plays his turn. Counts an ace as a 11 unless it means he busts. Always hits at 16 or less, and stays at 17 or more
	while true
		puts "#{dealer.getName()} is at #{dealer.getValue()[0]}"
		dealer.printHand()
		dealerValue = dealer.getValue()[0]
		#if dealer busts
		if dealerValue > 21
			puts "Dealer has busted. Any players who did not bust will win."
			break
		#if dealer needs to hit again
		elsif dealerValue <= 16
			returnStuff = hit(dealer, deck)
			deck = returnStuff
		#if dealer is at blackjack or stays
	    else
	    #nested if to facilitate break 
	    	if dealerValue == 21
	    		puts "Dealer hits blackjack!"
	    	else
	    		puts "Dealer stays at a value of #{dealerValue}"
	    	end
	    	break
	    end
	end
	return [deck, dealer]
end

				

def playEntireTurn(playerList, deck)
	#plays the turn for all players including dealer.
	#cycle through players, and all hands of each player
	for i in 0..playerList.count-1
		numHand = 0
		while numHand <  playerList[i].getNumHands()
			if i != playerList.count-1
				returnStuff = playSingleTurn(playerList[i], deck, numHand) #play the turn
				deck = returnStuff[0]
				playerList[i] = returnStuff[1]
				if !(returnStuff[2] == true) #if the turn did not result in a split, go to next hand
					numHand += 1             #else, stay on the same hand
				end
			else
				returnStuff = playTurnDealer(playerList[i], deck) #dealer plays turn according to the rules
				deck = returnStuff[0]
				playerList[i] = returnStuff[1]
				numHand += 1
			end
		end
	end
    
    #scoring to see who wins, for those who did not bust
    dealerValue = playerList.last.getValue()[0]
    j = 0
    #iterate through players and each hand
    while j < playerList.count - 1
        currPlayer = playerList[j]
        for numHand in 0..currPlayer.getNumHands() - 1
	    	currValue = currPlayer.getValue(numHand)[0]
	    	#if the player wins (closer to 21 (but less than or equal to it) than the dealer)
	    	if ((currValue > dealerValue) && (currValue <= 21)) || ((dealerValue > 21) && (currValue <= 21))
	    		currPlayer.setPot(currPlayer.getPot() + (2*currPlayer.getBet(numHand)/3).to_i )
	    		currPlayer.setBet(numHand, 0)
	    		puts "#{currPlayer.getName()}'s value of #{currValue} in hand #{numHand+1} beats the dealer. Your pot is #{currPlayer.getPot()}"
	    	#if the player loses (opposite of above)
	    	elsif (currValue < dealerValue) && (currValue <= 21)
	    		currPlayer.setPot(currPlayer.getPot() - currPlayer.getBet(numHand))
	    		currPlayer.setBet(numHand, 0)
	    		puts "#{currPlayer.getName()}'s value of #{currValue} in hand #{numHand+1} loses to the dealer. Your pot is #{currPlayer.getPot()}"
	    		#check to see if the player is bankrupt
	    		if currPlayer.getPot() == 0
					puts "You have no money left, you have lost."
				end
			#cgeck for a tieS
	    	elsif (currValue == 21 && dealerValue == 21)
	    		currPlayer.setBet(numHand, 0)
	    		puts "We have a tie. You neither win nor lose; you get your money back."
	    	end
	    end
	    #if a player is bankrupt, remove them from the table
	    if currPlayer.getPot() == 0
	    	playerList.delete_at(j)
	    else
	    	j += 1
	    end
    end
	return [deck, playerList]
end


#script starts here. class definitions in LiveRamp.rb, other functions that are called are defined above
deck = buildDeck()
#create dealer
dealer = Dealer.new('Dealer')
puts "Created the dealer."
#create the rest of the players
playerList = createPlayers()
playerList.push(dealer) #the last player is the dealer (gets dealt cards last)

while playerList.count > 1
	#deal cards and update the player list and deck
	playerList = placeBets(playerList)
	returnDeal = initialDeal(deck, playerList) #necessary because ruby does not use pass by reference
	deck = returnDeal[0]
	playerList = returnDeal[1]
	#dealer shows his second card
	playerList.last.showCard()
	#all players + dealer play
	returnDeal = playEntireTurn(playerList, deck)
	deck = returnDeal[0]
	playerList = returnDeal[1]

	#option to opt out
	puts "Do you want to stop playing?"
	answer = gets
	if answer.chomp == 'y'
		break
	else
		for i in playerList
			i.reset() 			#continue playing
			deck = buildDeck()
		end
	end

end

#ending messages
if playerList.count  == 1
	puts "All players have lost."
end
puts "Thank you for playing"
