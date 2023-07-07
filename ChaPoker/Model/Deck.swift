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
        
        // Create a deck with all possible cards
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                let card = Card(rank: rank, suit: suit)
                cards.append(card)
            }
        }
    }
    
    func shuffle() {
        cards.shuffle()
    }
    
    func dealHand() -> [Card]? {
         guard cards.count >= 2 else {
             // Not enough cards in the deck to deal
             return nil
         }
         
         var hand: [Card] = []
         
         // Deal two cards for the hand
         for _ in 1...2 {
             if let card = cards.popLast() {
                 hand.append(card)
             }
         }
         
         return hand
     }
}
