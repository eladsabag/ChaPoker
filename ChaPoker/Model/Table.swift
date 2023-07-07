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
    var players: [User]? // players that joined the table
    var currentRoundPlayers: Array<User?>? // players that plays the round, changes during the game
    var currentPlayerTurn: User? // the current player turn
    let maxPlayers: Int // max allowed players
    var playersCount: Int? // actual number of players joined table
    var gameState: GameState?
    var deck: Deck?
    var bigBlind: Int
    var smallBlind: Int
    var pot: Int
    var currentBet: Int
    var bigBlindPlayer: User?
    var smallBlindPlayer: User?
    var seats: [Seat]
    
    init(tableID: String, gameType: String, maxPlayers: Int, bigBlind: Int) {
        self.tableID = tableID
        self.gameType = gameType
        self.players = []
        self.currentRoundPlayers = []
        self.currentPlayerTurn = nil
        self.maxPlayers = maxPlayers
        self.playersCount = 0
        self.gameState = GameState.IDLE
        self.deck = Deck()
        self.bigBlind = bigBlind
        self.smallBlind = bigBlind / 2
        self.pot = 0
        self.currentBet = 0
        self.bigBlindPlayer = nil
        self.smallBlindPlayer = nil
        self.seats = (0..<maxPlayers).map { Seat(player: nil, seatIndex: $0) }
    }
    
    mutating func addPlayer(_ player: User) {
        if players == nil {
            players = []
        }
        currentPlayerTurn = player
        players?.append(player)
        playersCount = players?.count
        if let emptySeatIndex = seats.firstIndex(where: { $0.player == nil }) {
            seats[emptySeatIndex].player = player
        } else {
            // All seats are occupied, handle accordingly
            print("All seats are occupied.")
        }
    }
    
    mutating func removePlayer(_ player: User) {
        guard var players = players,
              let index = players.firstIndex(where: { $0.userId == player.userId }) else {
            return
        }
        
        players.remove(at: index)
        playersCount = players.count
        if let seatIndex = seats.firstIndex(where: { $0.player != nil && $0.player?.userId == player.userId }) {
            seats[seatIndex].player = nil
        } else {
            // Player not found, handle accordingly
            print("Player not found.")
        }
        
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
                for i in 0...(currentRoundPlayers!.count * 2) {
                    currentRoundPlayers![i]!.hand?.append(deck!.dealCard()!)
                }
            }
        } else {
            print("Insufficient players to start the game.")
        }
    }
    
    mutating func changeGameState(state: GameState) {
        switch state {
        case GameState.IDLE:
            // 1. Game isn't running yet, perform checks that everything is ready to start the game.
            // 2. Everything ready -> start game, else -> keep performing this checks
            // 3. Show pre-flop
            gameState = GameState.PREFLOP
            break
        case GameState.PREFLOP:
            // 1. Save current players to list of the players that in the hand
            // 2. Deal hands
            // 3. Check who has the Big Blind
            // 4. Let the players that in decide their move
            // 5. If someone raises then restart the turns
            // 6. Turns finished, show flop.
            if currentRoundPlayers?.count == 1 { // 1 Winner, everyone folded
                gameState = GameState.IDLE
            } else {
                gameState = GameState.FLOP
            }
            break
        case GameState.FLOP:
            // Do the same but show turn
            if currentRoundPlayers?.count == 1 { // 1 Winner, everyone folded
                gameState = GameState.IDLE
            } else {
                gameState = GameState.TURN
            }
            break
        case GameState.TURN:
            // Do the same but show river
            if currentRoundPlayers?.count == 1 { // 1 Winner, everyone folded
                gameState = GameState.IDLE
            } else {
                gameState = GameState.RIVER
            }
            break
        case GameState.RIVER:
            // Do the same but remove all cards from tables
            // 7. Determine winners
            // 8. Give money to winner/s
            gameState = GameState.IDLE
            break
        }
    }
    
    func abortGame() {
        
    }
}
