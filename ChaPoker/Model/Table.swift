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
        case GameState.REWARDS:
            gameState = GameState.REWARDS
            determineWinners()
            break
        }
        
    }
    
    func initGame() {
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
        resetPlayersMoves()
        resetPot()
        initSeatBigAndSmallBlinds()
        initCurrentRoundPlayerTurn()
        initRoundEndSeat()
    }
    
    /*
     This function init the current round seat big blind and small blind.
     If there isn't any record of previous big and small blind seats then it chooses
     the first and seconds seats as the big and small blinds.
     Additionally, it sets the initial current player turn,
     which is the seat after big blind.
     */
    func initSeatBigAndSmallBlinds() {
        let seatBigBlind = seats.first(where: { $0.isBigBlind })
        if seatBigBlind == nil {
            seats[0].isSmallBlind = true
            seats[1].isBigBlind = true
            makePayment(seatIndex: 0, payment: 1)
            makePayment(seatIndex: 1, payment: 2)
            return
        }
        
        var lastSeatIndex = -1
        let lastIndex = seats.count - 1
        for (i, seat) in seats.enumerated() {
            if seat.isBigBlind {
                seats[i].isBigBlind = false
                seats[i].isSmallBlind = true
                makePayment(seatIndex: i, payment: 1)
                
                let resetIndex = lastSeatIndex == -1 ? lastIndex : i - 1
                seats[resetIndex].isBigBlind = false
                seats[resetIndex].isSmallBlind = false
                
                let nextBigBlindIndex = i + 1 > lastIndex ? 0 : i + 1
                seats[nextBigBlindIndex].isBigBlind = true
                seats[nextBigBlindIndex].isSmallBlind = false
                makePayment(seatIndex: i, payment: 2)
            }
            lastSeatIndex = i
        }
    }
    
    /*
     This function will set the next seat after big blind as the current
     round player turn, and can be reusable every round initialization.
     */
    func initCurrentRoundPlayerTurn() {
        if currentPlayerSeatTurn == nil {
            if playersCount == 2 {
                currentPlayerSeatTurn = seats[0]
            } else {
                currentPlayerSeatTurn = seats[2]
            }
            return
        }
        
        let lastIndex = seats.count - 1
        for (i, seat) in seats.enumerated() {
            if seat.isBigBlind {
                let nextBigBlindIndex = i + 1 > lastIndex ? 0 : i + 1
                let currentPlayerTurnIndex = nextBigBlindIndex + 1 > lastIndex ? 0 : i + 1
                currentPlayerSeatTurn = seats[currentPlayerTurnIndex]
            }
        }
    }
    
    func initRoundEndSeat() {
        // TODO
        currentPlayerSeatTurn?.isRoundEndSeat = true
    }
    
    func resetPlayersMoves() {
        for seat in seats {
            seat.lastAction = Action.CHECK
        }
    }
    
    func resetPlayersRoundPayment() {
        for seat in seats {
            seat.roundPayment = 0
        }
    }
    
    func resetPot() {
        pot = 0
    }
    
    func updateRoundState(action: Action) {
        currentPlayerSeatTurn?.lastAction = action
        currentPlayerSeatTurn = findNextSeat()
        switch(action) {
        case Action.CHECK:
            // Do nothing
            break
        case Action.CALL:
            // Charge player payment
            // Update pot
            break
        case Action.BET:
            // Charge player payment
            // Update current bet
            // Update current round end seat
            // Update pot
            break
        case Action.FOLD:
            break
        }
        if let isEnd = currentPlayerSeatTurn?.isRoundEndSeat, isEnd {
            let state = gameState == GameState.IDLE ? GameState.PREFLOP :
                        gameState == GameState.PREFLOP ? GameState.FLOP :
                        gameState == GameState.FLOP ? GameState.TURN :
                        gameState == GameState.TURN ? GameState.RIVER : GameState.IDLE
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
    
    func determineWinners() {
        var hands: [(hand: [Card], description: String)] = []
        for seat in seats {
            if seat.isInGame() {
                let playerHand = seat.player?.hand
                let playerStrongestHand = GameValidator.findStrongestHand(flop: flop!, turn: turn!, river: river!, hand: playerHand!)
                print("Player \(seat.player!.name) Strongest Hand: \(playerStrongestHand)")
                hands.append(playerStrongestHand)
            }
        }

        let winners = GameValidator.determineWinners(hands.map { $0.hand })
        // TODO split money
        if winners.count == 1 {
            print("Player \(winners[0] + 1) is the winner!")
        } else if winners.count > 1 {
            print("It's a tie between players: \(winners.map { $0 + 1 })")
        } else {
            print("No winners found.")
        }
    }
    
    func makePayment(seatIndex: Int, payment: Int) {
        if seatIndex < seats.count {
            pot += payment

            seats[seatIndex].player?.chips -= payment
            seats[seatIndex].roundPayment += payment
        }
    }
}
