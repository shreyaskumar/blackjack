class Player
	def initialize(name)
		@name = name
		@handList = Array.new(1){Array.new}

		@numHands = 1
		@bet = [0]
		@pot = 1000
		@hasAce = false #flag to account for two possible scorings with aces
	end
    
    def getName()
    	return @name
    end

	def addCard(card, numHand = 0)
		@handList[numHand].push(card)
		if card.getName() == 'A'
			@hasAce = true
		end
	end

	def printHand(numHand = 0)
		puts "#{@name}'s hand (number #{numHand + 1}) is"
		for i in 0..@handList[numHand].count-1
			puts "#{@handList[numHand][i].getName()} of #{@handList[numHand][i].getSuit()}"
		end
	end

	def addHand(card)
		@handList.push(Array.new)
		self.addCard(card, @numHands)
		@numHands += 1
		@bet.push(@bet[-1])
	end
		
	def popCard(numHand)
		@handList[numHand].pop #to be called only when splitting hands to change the original hand to one card
	end

	def getNumHands()
		return @numHands
	end

	def setNumHands(num)
		@numHands = num
	end

	def getHand(num = 0)
		return @handList[num]
	end

	def getBet(numHand = 0)
		return @bet[numHand]
	end

	def setBet(numHand = 0, num)
		@bet[numHand] = num
	end

	def totalBet()
		return @bet.inject{|sum, x| sum + x}
	end

	def getPot()
		return @pot
	end

	def setPot(amount)
		@pot = amount
	end
   

    def getValue(num = 0)
    	value = 0
    	if @hasAce == true
    		altValue = 0
    	end
    	for i in @handList[num]
    		if i.getName() == 'A'
    			value += 11
    			altValue += 1
    		else
    			value += i.getCardValue()
    			if @hasAce == true
    				altValue += i.getCardValue()
    			end
    		end
    	end
    	if value > 21 && @hasAce == true
    		return [altValue]
    	else
    		return [value, altValue]
    	end
    end

    def existAce()
    	return @hasAce
    end


    def reset()
    	@numHands = 1
    	@handList = Array.new(1){Array.new}
    	@bet = [0]
    	@hasAce = false
    end
end

class Dealer < Player
	def showCard()
		puts "Dealer shows #{@handList[0][1].getName()} of #{@handList[0][1].getSuit()}"
	end

	def printHand(numHand = 0)
		puts "#{@name}'s hand is"
		for i in 0..@handList[numHand].count-1
			puts "#{@handList[numHand][i].getName()} of #{@handList[numHand][i].getSuit()}"
		end
	end
end


class Card
	def initialize(suit,name)
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
		return @name
	end

	def getCardValue()
		return @value
	end

	def getSuit()
		return @suit
	end
end


