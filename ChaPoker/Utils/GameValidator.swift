//
//  GameValidator.swift
//  ChaPoker
//
//  Created by Elad Sabag on 04/07/2023.
//
import Foundation

class GameValidator {
    static func findStrongestHand(flop: [Card], turn: Card, river: Card, hand: [Card]) -> (hand: [Card], description: String) {
        let allCards = flop + [turn, river] + hand
        let possibleHands = generatePossibleHands(allCards)
        let strongestHand = evaluateStrongestHand(possibleHands)
        return strongestHand
    }
    
    private static func generatePossibleHands(_ cards: [Card]) -> [[Card]] {
        var possibleHands: [[Card]] = []
        let combinations = cards.combinations(of: 5)
        for combination in combinations {
            possibleHands.append(Array(combination))
        }
        return possibleHands
    }
    
    private static func evaluateStrongestHand(_ possibleHands: [[Card]]) -> (hand: [Card], description: String) {
        var strongestHand: [Card] = []
        var strongestDescription = ""
        var strongestRankValue = 0

        for hand in possibleHands {
            let handRankValue = calculateHandRankValue(hand)
            let handDescription = describeHand(hand)
            
            if handRankValue > strongestRankValue {
                strongestRankValue = handRankValue
                strongestHand = hand
                strongestDescription = handDescription
            }
        }

        return (hand: strongestHand, description: strongestDescription)
    }

    private static func describeHand(_ hand: [Card]) -> String {
        if isRoyalFlush(hand) {
            return "Royal Flush"
        } else if isStraightFlush(hand) {
            return "Straight Flush"
        } else if isFourOfAKind(hand) {
            return "Four of a Kind"
        } else if isFullHouse(hand) {
            return "Full House"
        } else if isFlush(hand) {
            return "Flush"
        } else if isStraight(hand) {
            return "Straight"
        } else if isThreeOfAKind(hand) {
            return "Three of a Kind"
        } else if isTwoPair(hand) {
            return "Two Pair"
        } else if isPair(hand) {
            return "Pair"
        } else {
            return "High Card"
        }
    }

    
    private static func handDescription(_ hand: [Card]) -> String {
           let cardDescriptions = hand.map { $0.description }
           return cardDescriptions.joined(separator: ", ")
    }
    
    private static func calculateHandRankValue(_ hand: [Card]) -> Int {
        let sortedHand = hand.sorted { $0.rank.value < $1.rank.value }
        if isRoyalFlush(sortedHand) {
            return 10
        } else if isStraightFlush(sortedHand) {
            return 9
        } else if isFourOfAKind(sortedHand) {
            return 8
        } else if isFullHouse(sortedHand) {
            return 7
        } else if isFlush(sortedHand) {
            return 6
        } else if isStraight(sortedHand) {
            return 5
        } else if isThreeOfAKind(sortedHand) {
            return 4
        } else if isTwoPair(sortedHand) {
            return 3
        } else if isPair(sortedHand) {
            return 2
        } else {
            return 1 // High Card
        }
    }

    
    // Helper methods to check hand rankings
    
    private static func isRoyalFlush(_ hand: [Card]) -> Bool {
        let suit = hand[0].suit
        let ranks: Set<Rank> = [.ten, .jack, .queen, .king, .ace]
        
        return hand.allSatisfy { $0.suit == suit && ranks.contains($0.rank) } && hand.count == 5
    }
    
    private static func isStraightFlush(_ hand: [Card]) -> Bool {
        return isFlush(hand) && isStraight(hand)
    }
    
    private static func isFourOfAKind(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.contains(where: { $0.value == 4 })
    }
    
    private static func isFullHouse(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.contains(where: { $0.value == 3 }) && rankCounts.contains(where: { $0.value == 2 })
    }
    
    private static func isFlush(_ hand: [Card]) -> Bool {
        let suit = hand[0].suit
        return hand.allSatisfy { $0.suit == suit } && hand.count == 5
    }
    
    private static func isStraight(_ hand: [Card]) -> Bool {
        let sortedRanks = hand.map { $0.rank.value }.sorted()
        let distinctRanks = Set(sortedRanks)

        // Check for the special case: A, 2, 3, 4, 5 (Ace-low straight)
        if distinctRanks == Set([2, 3, 4, 5, 14]) {
            return true
        }

        // Check for regular straights
        if distinctRanks.count == 5 && sortedRanks.last! - sortedRanks.first! == 4 {
            return true
        }

        return false
    }
    
    private static func isThreeOfAKind(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.contains(where: { $0.value == 3 })
    }
    
    private static func isTwoPair(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        let pairCount = rankCounts.filter { $0.value == 2 }.count
        return pairCount == 2
    }
    
    private static func isPair(_ hand: [Card]) -> Bool {
        let rankCounts = getRankCounts(hand)
        return rankCounts.contains(where: { $0.value == 2 })
    }
    
    private static func getRankCounts(_ hand: [Card]) -> [Rank: Int] {
        var rankCounts: [Rank: Int] = [:]
        for card in hand {
            rankCounts[card.rank, default: 0] += 1
        }
        return rankCounts
    }
    
    static func determineWinners(_ handsMap: [Int: (hand: [Card], description: String)]) -> [(seatIndex: Int, hand: [Card])] {
        var winners: [(seatIndex: Int, hand: [Card])] = []
        var maxRankValue = 0
        
        // Find the maximum rank value among all the hands
        for (_, handDescription) in handsMap {
            let rankValue = calculateHandRankValue(handDescription.hand)
            if rankValue > maxRankValue {
                maxRankValue = rankValue
            }
        }
        
        // Find the hands with the maximum rank value (potential winners) and add them to the winners array
        for (seatIndex, handDescription) in handsMap {
            let rankValue = calculateHandRankValue(handDescription.hand)
            if rankValue == maxRankValue {
                let winner: (seatIndex: Int, hand: [Card]) = (seatIndex, handDescription.hand)
                winners.append(winner)
            }
        }
        
        return winners
    }

}

extension Array {
    func combinations(of length: Int) -> [[Element]] {
        guard length > 0 else {
            return [[]]
        }
        
        guard let first = first else {
            return []
        }
        
        let rest = Array(self[1...])
        let combinationsWithoutFirst = rest.combinations(of: length)
        let combinationsWithFirst = rest.combinations(of: length - 1).map { [first] + $0 }
        
        return combinationsWithoutFirst + combinationsWithFirst
    }
}
