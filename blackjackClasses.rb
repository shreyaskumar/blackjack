#defines the classes necessary for gameplay.rb (class Player and class Card)
#Shreyas Kumar

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

	def setBet(numHand = 0, num)
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


