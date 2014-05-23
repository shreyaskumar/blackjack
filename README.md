README for BlackJack (LiveRamp coding challenge)

To run, install Ruby and then execute
run gamePlay.rb

Requires ruby 2.00 (though the change to accomodate 1.8.7 is not a big one)

The game follows the standard rules of BlackJack. Cards are dealt to each player first, and then the dealer. The second card of the dealer is 'shown' to the other players. Ace can be valued at 1 or 11. Dealer always hits on 16 or less and stays on 17 or more. An Ace is counted as 11 for the dealer unless that would result in a bust (so a 17 with an Ace results in a stay for the dealer). The players get the chance to hit or stay before the dealer plays, as per usual rules. Players also have a chance to double down on their initial bet before hitting and splitting if they have two cards of the same value (e.g. J, 10 can be split). If a player is already at blackjack, they cannot doubledown. Splitting requires a player to place a bet of the same value on the split hand, so the option comes up only if the player has enough money to do so; same with doubling down. All players start with 1000 and can place any positive integer bet that is less than their pot. The house uses a 4 deck shoe, and every time the game is played, the shoe is reset. You can play as many games as you want, assuming you don't run out of money. There is no option (as of yet) for individual players to opt out, though the entire game can stop after any given run. The pay out for winning is 3:2 odds (rounded to the nearest integer). The board accepts a maximum of 12 players.
