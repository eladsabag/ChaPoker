//
//  User.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

class User: Codable {
    let userId: String
    var name: String
    var profilePictureUrl: URL?
    var chips: Int
    var hand: [Card]?
    var action: Action?
    
    init(userId: String, name: String, profilePictureUrl: URL?, chips: Int) {
        self.userId = userId
        self.name = name
        self.profilePictureUrl = profilePictureUrl
        self.chips = chips
        self.hand = []
        self.action = nil
    }
    
    func receiveCard(_ card: Card) {
        hand?.append(card)
    }
    
    func discardHand() {
        hand?.removeAll()
    }
}
