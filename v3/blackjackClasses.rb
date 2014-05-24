#defines the classes necessary for gameplay.rb (class Player and class Card)
#Shreyas Kumar

class Game
	def initialize()
		@deck = Array.new
		self.buildDeck()
		@playerList = Array.new
		self.createPlayers()
		@numPlayers = @playerList.count
	end

	def buildDeck()
		#no input
		#returns a shoe of 4 decks
		#Build the deck, required for any game
		#cycle through all possible cards
		#4 deck shoe
		for k in 1..4
			suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs']
			cards =  [2,3,4,5,6,7,8,9,10, 'J', 'Q', 'K',  'A']
			suits.product(cards).collect{|i, j| @deck.push(Card.new(i, j))}
		end
	end

	def getNumPlayers()
		return @numPlayers
	end

	def getDeck()
		return @deck
	end

	def createPlayers()
		#no input
		#returns an array of players
		#Creates a user specified number of players (maximum of 12, so the cards 
		#don't become too predictable)
	    @playerList.push(Player.new('Player 1'))
		puts "Created Player 1."
		#user determines how many players are necessary. The implementation could 
		#use less user input for example, only take in how many players are playing 
		#in the beginning
		while true
			if @playerList.count == 12
				puts "You have reached the maximum number of players at this table."
				break
			end
			puts "Do you want to add another player? [y/N]"
			answer = gets
			#create the list of players
			if answer.chomp == "y" #chomp gets rid of the newline character
				@playerList.push(Player.new('Player ' + (@playerList.count+1).to_s))
				puts "Created Player #{@playerList.count}"
			else
				break
			end
		end
		puts "We have #{@playerList.count} players at the table."

		dealer = Dealer.new('Dealer')
		@playerList.push(dealer) #the last player is the dealer (gets dealt cards last)
		puts "Created the dealer."
	end

	def dealCard(numPlayer, numHand = 0)
		#INPUT: the deck, player and hand to add card to
		#returns the modified deck and the player
		#deal a random card
		cardToDeal = @deck.sample() #change to choice for ruby1.8.7
		@playerList[numPlayer].addCard(cardToDeal, numHand)
		@deck.delete(cardToDeal) 
	end

	def initialDeal()
		#INPUT: takes in the deck and the list of players
		#returns a list with the deck and list of players
		#the first set of cards are dealt 
		#(two cards to each player including the dealer)
		for j in 0..1
			for numPlayer in 0..@playerList.count - 1
				dealCard(numPlayer,  0)
				#make sure we stay true to the game: you can still count cards!
			end
		end
		@playerList.last.showCard()
	end

	def placeBets()
		#INPUT: takes in the list of players
		#returns the modified list of players
		#method that allows each player to place bets. Bets can only be integers,
		#and have to be less than their pot.
		@playerList[0..-2].each do |player| #cycle through all players except for the
			while true 			  #dealer (dealer is the last element of playerList)
				puts "#{player.getName()}, place your bet."\
					 " Your pot is #{player.getPot()}."
				bet = gets
				if !(bet.chomp.class == Fixnum)
					"This game only accepts integer bets"
				end
				if bet.chomp.to_i == 0
					puts "You have to bet something to play."
				elsif bet.chomp.to_i <= player.getPot()
					player.setBet(bet.chomp.to_i, 0) #sets the specified bet
					break
				else
					puts "Your pot is not big enough to support that bet."
				end
			end
		end
	end

	def hit(numPlayer, numHand = 0)
		#INPUT: takes in the player, deck and number of hand 
		#returns a list with the deck and player
		#method that allows a player/dealer to hit
		dealCard(numPlayer, numHand)
		cardToDeal = @playerList[numPlayer].getHand(numHand).last
		puts "#{@playerList[numPlayer].getName()} has been dealt"\
		     " #{cardToDeal.getName()} of #{cardToDeal.getSuit()}"
	end

	
	def playTurnDealer()
		#INPUT: takes in the dealer and deck
		#returns a list with the deck and dealer
		#dealer plays his turn. Counts an ace as a 11 unless it means he busts.
		# Always hits at 16 or less, and stays at 17 or more
		while true
			puts "#{@playerList.last.getName()} is at #{@playerList.last.getValue()[0]}"
			@playerList.last.printHand()
			dealerValue = @playerList.last.getValue()[0]
			#if dealer busts
			if dealerValue > 21
				puts "Dealer has busted. Any players who did not bust will win."
				break
			#if dealer needs to hit again
			elsif dealerValue <= 16
				hit(@playerList.count-1, 0)
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
	end


	def playEntireTurn()
		#INPUT: takes in the deck and list of players
		#plays the turn for all players including dealer.
		#cycle through players, and all hands of each player
		for numPlayer in 0..@playerList.count - 1
			numHand = 0
			while numHand <  @playerList[numPlayer].getNumHands()
				if @playerList[numPlayer].getName() != 'Dealer'
					#play the turn
					bool = playSingleTurn(numPlayer, numHand) 
					#if the turn did not result in a split, go to next hand
					#else, stay on the same hand
					#NEEDS SOME TESTING HERE
					if ! bool
						numHand += 1             
					end
				else
					#dealer plays turn according to the rules
					playTurnDealer()
					numHand += 1
				end
			end
		end
	end
    
    def scoreTurn() 
	    #scoring to see who wins, for those who did not bust
	    dealerValue = @playerList.last.getValue()[0]
	    j = 0
	    #iterate through players and each hand
	    @playerList[0..-2].each do |currPlayer|
	        for numHand in 0..currPlayer.getNumHands() - 1
		    	currValue = currPlayer.getValue(numHand)[0]
		    	#if the player wins (closer to 21 
		    	#(but less than or equal to it) than the dealer)
		    	if ((currValue > dealerValue) && (currValue <= 21)) \
		    	  || ((dealerValue > 21) && (currValue <= 21))
		    		currPlayer.setPot(currPlayer.getPot() + \
		    		   (2*currPlayer.getBet(numHand)/3).to_i )
		    		currPlayer.setBet(0, numHand)
		    		puts "#{currPlayer.getName()}'s value of #{currValue} in hand"\
		    		     " #{numHand+1} beats the dealer."\
		    		     " Your pot is #{currPlayer.getPot()}"
		    	#if the player loses (opposite of above)
		    	elsif (currValue < dealerValue) && (currValue <= 21)
		    		currPlayer.setPot(currPlayer.getPot() \
		    		   - currPlayer.getBet(numHand))
		    		currPlayer.setBet(0, numHand)
		    		puts "#{currPlayer.getName()}'s value of #{currValue} in hand"\
		    		     " #{numHand+1} loses to the dealer."\
		    		     " Your pot is #{currPlayer.getPot()}"
		    		#check to see if the player is bankrupt
		    		if currPlayer.getPot() == 0
						puts "You have no money left, you have lost."
					end
				#check for a ties
		    	elsif (currValue == dealerValue)
		    		currPlayer.setBet(0, numHand)
		    		puts "We have a tie. #{currPlayer.getName()} neither wins"\
		    		     " nor loses; you get your money back."
		    	end
		    end
		    #if a player is bankrupt, remove them from the table
		    if currPlayer.getPot() == 0
		    	playerList.delete_at(j)
		    	@numPlayers -= 1
		    else
		    	j += 1
		    end
	    end
	end

	def playSingleTurn(numPlayer, numHand = 0)
		#INPUT: takes in the player, deck and hand to play
		#returns a list with the deck and player
		#plays the turn of one player

		puts "#{@playerList[numPlayer].getName()}'s turn, hand #{numHand + 1}."

		#in case this is a split hand with just one card, draw the second card
		hand = @playerList[numPlayer].getHand(numHand)
		if hand.count == 1
			hit(numPlayer, numHand)
		end

		#print out the hand values and the handfor player convenience
		if @playerList[numPlayer].getValue(numHand)[1] != nil
			puts "#{@playerList[numPlayer].getName()} is at #{@playerList[numPlayer].getValue(numHand)[0]}"\
			     " with A at 11 or at #{@playerList[numPlayer].getValue(numHand)[1]} with A at 1"
		else
			puts "#{@playerList[numPlayer].getName()} is at #{@playerList[numPlayer].getValue(numHand)[0]}"
		end
		@playerList[numPlayer].printHand(numHand)
		
		#check for blackjack on initial deal
		if @playerList[numPlayer].getValue(numHand)[0] == 21
			puts "You have hit blackjack!"\
			     " Now wait for the dealer's turn to decide winnings."
			return false
		end

		#ask the user if he/she wants to split. Checks to make sure both cards are 
		#the same, there are only two cards, and the player can afford the second
		#bet in the split
		if hand.count == 2 && hand[0].getCardValue() == hand[1].getCardValue()\
		 && ((@playerList[numPlayer].totalBet() + @playerList[numPlayer].getBet(numHand)) <= @playerList[numPlayer].getPot()) 
			puts "Do you want to split? [y/N]"
			answerSplit = gets
			if answerSplit.chomp == 'y'
				@playerList[numPlayer].addHand()
				return true
			end
		end

		#check if the user wants to double down.
		#Again, only possible if player has enough money
		if (@playerList[numPlayer].totalBet() + @playerList[numPlayer].getBet(numHand)) <= @playerList[numPlayer].getPot()
			puts "Do you wish to double down? [y/N]"
			answer = gets
			if answer.chomp == 'y'
				#change the bet to double the initial
				@playerList[numPlayer].setBet(2*@playerList[numPlayer].getBet(numHand), numHand) 
			end
		end
		flag = false #to print the hand in the while loop
		while true
			if flag
				#prints the hand value and hand for user convenience as he/she hits
				if @playerList[numPlayer].getValue(numHand)[1] != nil
					puts "#{@playerList[numPlayer].getName()} is at #{@playerList[numPlayer].getValue(numHand)[0]}"\
					     " with A at 11 or at #{@playerList[numPlayer].getValue(numHand)[1]} with"\
					     " A at 1"
				else
					puts "#{@playerList[numPlayer].getName()} is at #{@playerList[numPlayer].getValue(numHand)[0]}"
				end
				@playerList[numPlayer].printHand(numHand)
			end
			flag = true
			puts "Do you want to hit or stay? [h/s]"
			answer = gets
			#is user hits
			if answer.chomp == 'h'
				hit(numPlayer, numHand)
				#if the player busts, change the pot, reset the bet
				if @playerList[numPlayer].getValue(numHand)[0] > 21
					puts "#{@playerList[numPlayer].getName()} has busted with hand #{numHand + 1}."\
					     " You lose your bet of #{@playerList[numPlayer].getBet()}."
					@playerList[numPlayer].setPot(@playerList[numPlayer].getPot() - @playerList[numPlayer].getBet(numHand))
					@playerList[numPlayer].setBet(0, numHand)
					puts "Your pot is now #{@playerList[numPlayer].getPot()}."
					#check if the player has lost all his/her money. 
					if @playerList[numPlayer].getPot() == 0
						puts "You have no money left, you have lost."
						break
					end
					break
				#player at blackjack
				elsif @playerList[numPlayer].getValue(numHand)[0] == 21
					puts "You have hit blackjack!"\
					     " Now wait for the dealer's turn to decide winnings."
					break
				end
			#player stays
			elsif answer.chomp == 's'
				puts "You chose to stay. Your hand's value is"\
				     " #{@playerList[numPlayer].getValue(numHand)[0]}. Now wait for the dealer's"\
				     " turn to decide winnings."
				break
			else
				puts "Invalid response. h for Hit, s for Stay."
			end
		end
		return false
	end

	def check()
		puts "Do you want to keep playing? [Y/n]"
		answer = gets
		if answer.chomp == 'n'
			return true
		else
			@playerList.each do |player|
				player.reset() 			#continue playing
			end
			@deck = Array.new
			buildDeck()
			return false
		end
	end

	def end()
		if @playerList.count  == 1
			puts "All players have lost."
		else
			@playerList[0..-2].each do |player|
				puts "#{player.getName()} leaves the game with a pot of #{player.getPot()}"
			end
		end
		puts "Thank you for playing"
	end
end



class Player
	#the basic blackjack player
	def initialize(name)
		#initializes a player with a name
		#other variables to be instantiated include the list of Hands 
		#(usually just 1, can be more than 1 for a split)
		#numHands: the number of hands
		#list of bets that correspond to the hands. Note that bets can be
		#different on split hands since you can double down after splitting
		#pot represents the total money the player has
		#finally an ace flag to facilitate scoring
		@name = name
		@handList = Array.new(1){Array.new}

		@numHands = 1
		@bet = [0]
		@pot = 1000
		@hasAce = false 
	end
    
    def getName()
    	#no input; returns the player's name: primarily for the UI output
    	return @name
    end

	def addCard(card, numHand = 0)
		#INPUT: card to add, and the number of the hand to add to (default 0)
		#adds a card to the specified hand
		#no output
		@handList[numHand].push(card)
		if card.getName() == 'A'
			@hasAce = true #set the ace flag to true when required
		end
	end

	def printHand(numHand = 0)
		#INPUT: number of hand to print
		#no output
		#prints the specified hand out in a nice format
		puts "#{@name}'s hand (number #{numHand + 1}) is"
		@handList[numHand].each do |card|
			puts "#{card.getName()} of #{card.getSuit()}"
		end
	end

	def addHand()
		#no input
		#adds a hand to the player. Used only when split.
		@handList.push(Array.new)
		card = @handList[@numHands-1].pop #gets rid of the additional card  
		                                #in the first hand after pop
		self.addCard(card, @numHands)
		@numHands += 1
		@bet.push(@bet[-1])
	end
		

	def getNumHands()
		#no input
		#returns the number of hands
		return @numHands
	end

	def getHand(num = 0)
		#INPUT: optional, number of hand
		#returns the specified hand
		return @handList[num]
	end

	def getBet(numHand = 0)
		#INPUT: optional number of hand
		#returns the bet associated with the specified hand
		return @bet[numHand]
	end

	def setBet(num, numHand = 0)
		#INPUT: optional number of hand, and the bet value
		#sets the bet of numHand hand to num
		@bet[numHand] = num
	end

	def totalBet()
		#no input
		#returns the total outstanding bet over all hands
		return @bet.inject{|sum, x| sum + x}
	end

	def getPot()
		#no input
		#returns total amount of money available, or the pot
		return @pot
	end

	def setPot(amount)
		#INPUT: value of pot to set to
		#sets the pot (total money available)
		@pot = amount
	end
   

    def getValue(num = 0)
    	#INPUT: optional input of number of hand
    	#returns the value of the specifed (through num) hand
    	value = 0
    	if @hasAce == true
    		altValue = 0 #alternate scoring with an ace
    	end
    	@handList[num].each do |card|
    		if card.getName() == 'A'
    			value += 11 #default score of 11
    			altValue += 1
    		else
    			#scoring for all other cards
    			value += card.getCardValue()
    			if @hasAce == true
    				altValue += card.getCardValue()
    			end
    		end
    	end
    	 #if scoring an ace as 11 results in a bust, only score as a 1
    	if value > 21 && @hasAce == true
    		return [altValue]
    	#return both values if no bust occurs, the choice is upto the user
    	else
    		return [value, altValue] 
    	end
    end

    def reset()
    	#no input
    	#at the end of a round, resets all initial parameters to their defaults
    	@numHands = 1
    	@handList = Array.new(1){Array.new}
    	@bet = [0]
    	@hasAce = false
    end
end

class Dealer < Player
	#dealer class that is an extension of the player class
	def showCard()
		#no input
		#method to show the second card of the dealer
		puts "Dealer shows #{@handList[0][1].getName()}"\
		     " of #{@handList[0][1].getSuit()}"
	end

	def printHand(numHand = 0)
		#INPUT: optional input of number of hand
		#prints the specified hand out, each card on a new line
		puts "#{@name}'s hand is"
		@handList[numHand].each do |card|
			puts "#{card.getName()} of #{card.getSuit()}"
		end
	end
end


class Card
	#card class that is used to build the deck
	def initialize(suit,name)
		#three instantiation parameters:
		#the name, suit and blackjack value. 
		#Number cards have the same value as the number, 
		#face cards are worth 10 and ace is 11 or 1.
		@suit = suit
		@name = name
		if name.class == Fixnum
			@value = name
		elsif name == "A"
			@value = [1, 11]
		else
			@value = 10
		end
	end

	def getName()
		#no input
		#returns the name of the card
		return @name
	end

	def getCardValue()
		#no input
		#returns the value of the card
		return @value
	end

	def getSuit()
		#no input
		#returns the suit of the card
		return @suit
	end
end


