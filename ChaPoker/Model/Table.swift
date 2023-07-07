//
//  Table.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

struct Table: Codable {
    let tableID: String
    let gameType: String
    var players: [User]?
    var currentRoundPlayers: [User]?
    var currentPlayerTurn: User?
    let maxPlayers: Int
    var playersCount: Int?
    var gameState: GameState?
    var deck: Deck?
    var bigBlind: Int
    var smallBlind: Int
    
    init(tableID: String, gameType: String, maxPlayers: Int, bigBlind: Int) {
        self.tableID = tableID
        self.gameType = gameType
        self.maxPlayers = maxPlayers
        self.bigBlind = bigBlind
        self.smallBlind = bigBlind / 2
        self.players = []
        self.currentPlayerTurn = nil
        self.playersCount = 0
        self.gameState = GameState.PREFLOP
        self.deck = Deck()
        self.currentRoundPlayers = []
    }
    
    mutating func addPlayer(_ player: User) {
        if players == nil {
            players = []
        }
        players?.append(player)
        playersCount = players?.count
    }
    
    mutating func removePlayer(_ player: User) {
        guard var players = players,
              let index = players.firstIndex(where: { $0.userId == player.userId }) else {
            print("Player \(player.userId) not found at the table(table count = \(players?.count).")
            return
        }
        
        players.remove(at: index)
        playersCount = players.count
        
        if players.isEmpty {
            self.players = nil
        }
    }
    
    mutating func startGame() {
        if let players = players, players.count >= 2 {
            currentPlayerTurn = players[0]
            currentRoundPlayers = players
            gameState = GameState.PREFLOP
            deck?.loadDeckOfCards()
            deck?.shuffle()
            if currentRoundPlayers != nil && currentRoundPlayers?.isEmpty == false {
                for i in 0...currentRoundPlayers!.count {
                    currentRoundPlayers![i].hand = deck?.dealHand()
                }
            }
            
        } else {
            print("Insufficient players to start the game.")
        }
    }
    
    mutating func changeGameState(state: GameState) {
        switch state {
        case GameState.PREFLOP:
            break
        case GameState.FLOP:
            break
        case GameState.TURN:
            break
        case GameState.RIVER:
            break
        default:
            break
        }
    }
}
