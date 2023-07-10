//
//  Seat.swift
//  ChaPoker
//
//  Created by Elad Sabag on 08/07/2023.
//

import Foundation

class Seat: Codable {
    var player: User?
    var seatIndex: Int
    var isBigBlind: Bool
    var isSmallBlind: Bool
    var lastAction: Action
    var roundPayment: Int
    var isRoundEndSeat: Bool
    
    init(player: User? = nil, seatIndex: Int, isBigBlind: Bool, isSmallBlind: Bool, lastAction: Action = Action.CHECK) {
        self.player = player
        self.seatIndex = seatIndex
        self.isBigBlind = isBigBlind
        self.isSmallBlind = isSmallBlind
        self.lastAction = lastAction
        self.roundPayment = 0
        self.isRoundEndSeat = false
    }
    
    func isInGame() -> Bool {
        return !isSeatEmpty() && lastAction != Action.FOLD
    }
    
    func isSeatEmpty() -> Bool {
        return player == nil
    }
    
    func hasCards() -> Bool {
        return !isSeatEmpty() && player?.hand != nil && player?.hand?.count == 2
    }
    
    func isMySeat(userId: String) -> Bool {
        return !isSeatEmpty() && player?.userId == userId
    }
}


