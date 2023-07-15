//
//  Tester.swift
//  ChaPoker
//
//  Created by Elad Sabag on 08/07/2023.
//

import Foundation

class Tester {
    
    static func testAceLowStraight() {
        let flop = [Card(rank: .two, suit: .hearts), Card(rank: .three, suit: .clubs), Card(rank: .four, suit: .diamonds)]
        let turn = Card(rank: .five, suit: .spades)
        let river = Card(rank: .ace, suit: .hearts)

        let hand = [Card(rank: .ace, suit: .clubs), Card(rank: .two, suit: .hearts)]

        let strongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: hand)

        print("Strongest Hand: \(strongestHand)")
    }

    
    static func testGameValidator() {
        let flop = [Card(rank: .two, suit: .hearts), Card(rank: .king, suit: .hearts), Card(rank: .queen, suit: .hearts)]
        let turn = Card(rank: .jack, suit: .hearts)
        let river = Card(rank: .ten, suit: .hearts)

        let player1Hand = [Card(rank: .nine, suit: .hearts), Card(rank: .eight, suit: .hearts)]
        let player2Hand = [Card(rank: .ace, suit: .clubs), Card(rank: .king, suit: .clubs)]
        let player3Hand = [Card(rank: .ace, suit: .spades), Card(rank: .king, suit: .spades)]

        let player1StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player1Hand)
        let player2StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player2Hand)
        let player3StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player3Hand)

        let strongestHands = [player1StrongestHand, player2StrongestHand, player3StrongestHand]

        print("Player 1 Strongest Hand: \(player1StrongestHand.description)")
        print("Player 2 Strongest Hand: \(player2StrongestHand.description)")
        print("Player 3 Strongest Hand: \(player3StrongestHand.description)")

        var handsMap: [Int: (hand: [Card], description: String)] = [:]
        
        handsMap[0] = player1StrongestHand
        handsMap[1] = player2StrongestHand
        handsMap[2] = player3StrongestHand

        let winners = GameValidator.determineWinners(handsMap)
        if winners.count == 1 {
            let winner = winners[0]
            print("Winner: \(winner.hand[0].description), \(winner.hand[1].description)")
        } else {
            var winnerDetails = "Winners:"
            for winner in winners {
                winnerDetails += "\n\(winner.hand[0].description), \(winner.hand[1].description)"
            }
            winnerDetails += " !"
            print(winnerDetails)
        }
    }
}
