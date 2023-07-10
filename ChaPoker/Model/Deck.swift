//
//  Deck.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

class Deck : Codable {
    var cards: [Card]
    
    init() {
        cards = []
     }
    
    func loadDeckOfCards() {
        cards = []
        print("load deck of cards")
        // Create a deck with all possible cards
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                let card = Card(rank: rank, suit: suit)
                print("Added card \(card.description)")
                cards.append(card)
            }
        }
    }
    
    func shuffle() {
        cards.shuffle()
    }
    
    func dealCard() -> Card? {
        if let card = cards.popLast() {
            print(card.description)
            return card
        }
        return nil
     }
}
