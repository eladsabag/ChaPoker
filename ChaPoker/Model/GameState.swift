//
//  GameState.swift
//  ChaPoker
//
//  Created by Elad Sabag on 02/07/2023.
//

import Foundation

enum GameState : String, Codable {
    case IDLE = "IDLE"
    case PREFLOP = "PREFLOP"
    case FLOP = "FLOP"
    case TURN = "TURN"
    case RIVER = "RIVER"
    case REWARDS = "REWARDS"
}
