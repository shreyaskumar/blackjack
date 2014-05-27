#defines the classes necessary for gameplay.rb (class Player and class Card)
#Shreyas Kumar

class Game
	#class for the game object which runs the game. also stores the two 
	#important data structures: the list of players and the deck of cards
	def initialize()
		@deck = Array.new
		#build the deck
		self.buildDeck()
		@playerList = Array.new
		#create players
		self.createPlayers()
		#facilitate deletion of players on losing
		@numPlayers = @playerList.count
	end

	def buildDeck()
		#no input
		#no output
		#Build the deck, required for any game
		#cycle through all possible cards
		#4 deck shoe
		for k in 1..4
			suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs']
			cards =  [2,3,4,5,6,7,8,9,10, 'J', 'Q', 'K',  'A']
			#all possible combinations of suits and cards forms the deck
			suits.product(cards).collect{|i, j| @deck.push(Card.new(i, j))}
		end
	end

	def createPlayers()
		#no input
		#no output
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
		#INPUT: number denoting the player and number of hand to deal to
		#no output
		#deal a random card
		cardToDeal = @deck.sample() #change to choice for ruby1.8.7
		@playerList[numPlayer].addCard(cardToDeal, numHand)
		@deck.delete(cardToDeal) 
	end

	def initialDeal()
		#no input or output
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
		#no input or output
		#method that allows each player to place bets. Bets can only be 
		#positive integers and have to be less than their pot.
		@playerList[0..-2].each do |player| #cycle through all players except for the
			while true 			  #dealer (dealer is the last element of playerList)
				puts "#{player.getName()}, place your bet."\
					 " Your pot is #{player.getPot()}."
				bet = gets
				if !(bet.chomp.class == Fixnum)
					"This game only accepts integer bets"
				end
				if bet.chomp.to_i <= 0
					puts "You're bet has to be a positive integer."
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
		#INPUT: takes in the number denoting the player and the number of hand
		#no output
		#method that allows a player/dealer to hit
		dealCard(numPlayer, numHand)
		cardToDeal = @playerList[numPlayer].getHand(numHand).last
		puts "#{@playerList[numPlayer].getName()} has been dealt"\
		     " #{cardToDeal.getName()} of #{cardToDeal.getSuit()}"
	end

    
	
	def playTurnDealer()
		#no input or outpu
		#dealer plays his turn. Counts an ace as a 11 unless it means he busts.
		# Always hits at 16 or less, and stays at 17 or more
		while true
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
		#INPUT: no input or outpur
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
					if !bool
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
    	#no input or output
	    #scoring to see who wins, for those who did not bust
	    dealerValue = @playerList.last.getValue()[0]
	    j = 0
	    #iterate through players and each hand
	    @playerList[0..-2].each do |currPlayer|
	        for numHand in 0..currPlayer.getNumHands() - 1
	        	#scores the hand depending on the relative value of the hand to the dealer's hand
		    	currPlayer.scoreHand(numHand, dealerValue)
		    end
		    #if a player is bankrupt, remove them from the table
		    if currPlayer.getPot() == 0
				puts "#{currPlayer.getName()} has no money left, you have lost."
		    	playerList.delete_at(j)
		    	@numPlayers -= 1
		    else
		    	j += 1
		    end
	    end
	end

	def playSingleTurn(numPlayer, numHand = 0)
		#INPUT: takes in the number denoting the player and the number of the hand returns a 
		#boolean denoting if a split occured, true if it did occur plays the turn of one player
		puts "#{@playerList[numPlayer].getName()}'s turn, hand #{numHand + 1}."
		#in case this is a split hand with just one card, draw the second card
		if @playerList[numPlayer].getHand(numHand).count == 1
			hit(numPlayer, numHand)
		end
		#print out the hand values and the handfor player convenience
		@playerList[numPlayer].printHand(numHand)
		if @playerList[numPlayer].atBlackjack(numHand) #check for blackjack on initial deal
			return false
		end
		if @playerList[numPlayer].split(numHand) #ask the user if he/she wants to split. 
			#return true if there is a split
			return true
		end
		#check if the user wants to double down, again, only possible if player has enough money
		@playerList[numPlayer].doubleDown(numHand)
		flag = false #to print the hand in the while loop
		while true
			if flag
				#prints the hand value and hand for user convenience as he/she hits
				@playerList[numPlayer].printHand(numHand)
			end
			flag = true
			puts "Do you want to hit or stay? [h/s]"
			answer = gets
			#is user hits
			case answer.chomp
			when 'h'
				hit(numPlayer, numHand)
				#if the player busts, change the pot, reset the bet
				if @playerList[numPlayer].hasBusted(numHand)
					return false
				#player at blackjack
				elsif @playerList[numPlayer].atBlackjack(numHand)
					return false
				end
			#player stays
			when 's'
				puts "You chose to stay. Your hand's value is"\
				     " #{@playerList[numPlayer].getValue(numHand)[0]}. Now wait for the dealer's"\
				     " turn to decide winnings."
				return false
			else
				puts "Invalid response. h for Hit, s for Stay."
			end
		end
	end

	def check()
		#no input, boolean output that determines if the players want to keep playing
		#output of true if they want to stop, default answer is yes
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
		#no input or output
		#exit messages where each person still in the game have their pots displayed
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
		#prints the value and contents of a specified hand out in a nice format
		if getValue(numHand)[1] != nil #has an ace and it can be counted as a 11
			puts "#{@name} is at #{getValue(numHand)[0]}"\
			     " with A at 11 or at #{getValue(numHand)[1]} with A at 1"
		else
			puts "#{@name} is at #{getValue(numHand)[0]}"
		end
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

    #game methods
    def atBlackjack(numHand= 0)
    	#optional input of the number of hand to check. outputs a bool, true if at blackjack
    	if getValue(numHand)[0] == 21
			puts "You have hit blackjack!"\
			     " Now wait for the dealer's turn to decide winnings."
			return true
		end
		return false
    end

    def hasBusted(numHand = 0)
    	#optional input of the number of hand to check, outputs a bool, true if player has busted
    	if getValue(numHand)[0] > 21
			puts "#{@name} has busted with hand #{numHand + 1}."\
			     " You lose your bet of #{@bet[numHand]}."
			@pot = @pot - @bet[numHand]
			@bet[numHand] = 0
			puts "Your pot is now #{@pot}."
			return true
		end
	end

	def split(numHand = 0)
		#optional input of the number of the hand to split, bool output, true if the player decides
		#to split
		#Checks to make sure both cards are the same, there are only two cards, 
		#and the player can afford the second bet in the split
		if @handList[numHand].count == 2 && @handList[numHand][0].getCardValue() ==\
		 @handList[numHand][1].getCardValue() && (totalBet() +@bet[numHand]) <= @pot 
			puts "Do you want to split? [y/N]"
			answerSplit = gets
			if answerSplit.chomp == 'y'
				addHand()
				return true
			end
		end
		return false
	end

	def doubleDown(numHand = 0)
		#no input or output, queries and executes doubling down if the player desires to do so
    	if (totalBet() + @bet[numHand]) <= @pot
			puts "Do you wish to double down? [y/N]"
			answer = gets
			if answer.chomp == 'y'
				#change the bet to double the initial
				@bet[numHand] = 2*@bet[numHand] 
			end
		end
    end

    def scoreHand(numHand, dealerValue)
    	#takes in the  the number of the hand and the value of the dealer's hand to compare against
    	#no output, scores for all cases except if the player busted on hitting
    	currValue = getValue(numHand)[0]
    	#if the player beats the dealer
    	if ((currValue > dealerValue) && (currValue <= 21)) \
    	  || ((dealerValue > 21) && (currValue <= 21))
    		@pot = @pot + (2*@bet[numHand]/3).to_i 
    		@bet[numHand] = 0
    		puts "#{@name}'s value of #{currValue} in hand"\
    		     " #{numHand+1} beats the dealer. Your pot is #{@pot}"
    	#if the player loses (opposite of above)
    	elsif (currValue < dealerValue) && (currValue <= 21)
    		@pot = @pot - @bet[numHand]
    		@bet[numHand] = 0
    		puts "#{@name}'s value of #{currValue} in hand"\
    		     " #{numHand+1} loses to the dealer."\
    		     " Your pot is #{@pot}"	
		#check for a ties
    	elsif (currValue == dealerValue)
    		@bet[numHand] = 0
    		puts "We have a tie. #{@name} neither wins"\
    		     " nor loses; you get your money back."
    	end
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
		#prints the value and contents of a specified hand out,
		#each card on a new line
		puts "#{@name} is at #{getValue()[0]}"
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


