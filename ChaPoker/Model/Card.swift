//
//  Card.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

class Card : Codable{
    let rank: Rank
    let suit: Suit
    
    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    var description: String {
        return "\(rank.rawValue) of \(suit.rawValue)"
    }
    
    var imageName: String {
        return "\(rank.rawValue.lowercased())_\(suit.rawValue.lowercased())"
    }
}
