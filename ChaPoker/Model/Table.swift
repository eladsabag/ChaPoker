//
//  Table.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

class Table: Codable {
    let tableID: String
    let gameType: String
    var currentPlayerSeatTurn: Seat? // the current player turn
    let maxPlayers: Int // max allowed players
    var playersCount: Int // actual number of players joined table
    var gameState: GameState
    var deck: Deck?
    var bigBlind: Int
    var smallBlind: Int
    var pot: Int
    var currentBet: Int
    var seats: [Seat]
    var flop: [Card]?
    var turn: Card?
    var river: Card?
    
    init(tableID: String, gameType: String, maxPlayers: Int, bigBlind: Int) {
        self.tableID = tableID
        self.gameType = gameType
        self.currentPlayerSeatTurn = nil
        self.maxPlayers = maxPlayers
        self.playersCount = 0
        self.gameState = GameState.IDLE
        self.deck = nil
        self.bigBlind = bigBlind
        self.smallBlind = bigBlind / 2
        self.pot = 0
        self.currentBet = 0
        self.seats = (0..<maxPlayers).map { Seat(player: nil, seatIndex: $0, isBigBlind: false, isSmallBlind: false, lastAction: Action.CHECK) }
        self.flop = []
        self.turn = nil
        self.river = nil
    }
    
    func addPlayer(_ player: User) {
        playersCount += 1
        if let emptySeatIndex = seats.firstIndex(where: { $0.player == nil }) {
            seats[emptySeatIndex].player = player
        } else {
            // All seats are occupied, handle accordingly
            print("All seats are occupied.")
        }
    }
    
    func removePlayer(_ player: User) {
        playersCount -= 1
        if let seatIndex = seats.firstIndex(where: { $0.player != nil && $0.player?.userId == player.userId }) {
            seats[seatIndex].player = nil
        } else {
            // Player not found, handle accordingly
            print("Player not found.")
        }
    }
    
    func startGame() {
        if gameState == GameState.IDLE && playersCount >= 2 {
            print("Starting game...")
            changeGameState(state: GameState.PREFLOP)
        } else {
            print("Insufficient players to start the game.")
        }
    }
    
    func changeGameState(state: GameState) {
        switch state {
        case GameState.IDLE:
            gameState = GameState.IDLE
            break
        case GameState.PREFLOP:
            gameState = GameState.PREFLOP
            initGame()
            break
        case GameState.FLOP:
            gameState = GameState.FLOP
            dealFlop()
            break
        case GameState.TURN:
            gameState = GameState.TURN
            dealTurn()
            break
        case GameState.RIVER:
            gameState = GameState.RIVER
            dealRiver()
            break
        }
        
    }
    
    func initGame() {
        resetPlayersMoves()
        currentPlayerSeatTurn = seats.first(where: { $0.player != nil }) // TODO
        flop = []
        turn = nil
        river = nil
        deck = Deck()
        deck?.loadDeckOfCards()
        deck?.shuffle()
        // deal hands to players
        for seat in seats {
            if !seat.isSeatEmpty() {
                if seat.player?.hand == nil {
                    seat.player?.hand = []
                }
                if let card = deck?.dealCard() {
                    seat.player!.hand!.append(card)
                } else {
                    print("Card nil")
                }
            }
        }
        for seat in seats {
            if !seat.isSeatEmpty() {
                if seat.player?.hand == nil {
                    seat.player?.hand = []
                }
                seat.player!.hand?.append(deck!.dealCard()!)
            }
        }
        // TODO init seats for big, small blinds, and round end seat
        currentPlayerSeatTurn?.isRoundEndSeat = true
    }
    
    func resetPlayersMoves() {
        for seat in seats {
            seat.lastAction = Action.CHECK
        }
    }
    
    func updateRoundState(action: Action) {
        currentPlayerSeatTurn?.lastAction = action
        currentPlayerSeatTurn = findNextSeat()
        switch(action) {
        case Action.CHECK:
            break
        case Action.CALL:
            break
        case Action.BET:
            break
        case Action.FOLD:
            break
        }
        if let isEnd = currentPlayerSeatTurn?.isRoundEndSeat, isEnd {
            // TODO
            let state = gameState == GameState.PREFLOP ? GameState.FLOP : gameState == GameState.FLOP ? GameState.TURN : gameState == GameState.TURN ? GameState.RIVER : gameState == GameState.RIVER ? GameState.IDLE : GameState.PREFLOP
            changeGameState(state: state)
        }
    }
    
    func findNextSeat() -> Seat? {
        let mySeatIndex = currentPlayerSeatTurn?.seatIndex
        var currentIndex = (mySeatIndex! + 1) % seats.count  // Starting index

        while currentIndex != mySeatIndex {
            let seat = seats[currentIndex]

            if seat.isInGame() && seat.isSeatEmpty() == false {
                return seat
            }

            currentIndex = (currentIndex + 1) % seats.count  // Move to the next index
        }

        return nil  // If no seat is found
    }
    
    func dealFlop() {
        flop = []
        let burnedCard = deck?.dealCard() // burned card
        for _ in 0..<3 {
            let flopCard = deck?.dealCard()
            flop?.append(flopCard!)
        }
    }
    
    func dealTurn() {
        let burnedCard = deck?.dealCard() // burned card
        turn = deck?.dealCard()!
    }
    
    func dealRiver() {
        let burnedCard = deck?.dealCard() // burned card
        river = deck?.dealCard()!
    }
}
