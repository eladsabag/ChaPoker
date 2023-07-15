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
    var winnerDetails: String
    
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
        self.winnerDetails = ""
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
        reset()
        flop = []
        turn = nil
        river = nil
        deck = Deck()
        deck?.loadDeckOfCards()
        deck?.shuffle()
        dealHandToPlayers()
        initSeatBigAndSmallBlinds()
        findNextSeat()
        initRoundEndSeat() // TODO
    }
    
    func reset() {
        pot = 0
        currentBet = bigBlind
        winnerDetails = ""
        for seat in seats {
            seat.lastAction = Action.CHECK
            seat.roundPayment = 0
            seat.totalPayment = 0
        }
    }
    
    func dealHandToPlayers() {
        for seat in seats {
            if !seat.isSeatEmpty() {
                if seat.player?.hand == nil || seat.player?.hand?.count == 2 {
                    seat.player?.hand = []
                }
                if let card = deck?.dealCard() {
                    seat.player!.hand!.append(card)
                }
            }
        }
        for seat in seats {
            if !seat.isSeatEmpty() {
                seat.player!.hand?.append(deck!.dealCard()!)
            }
        }
    }
    
    /*
     This function init the current round seat big blind and small blind.
     If there isn't any record of previous big and small blind seats then it chooses
     the first and seconds seats as the big and small blinds.
     Additionally, it sets the initial current player turn,
     which is the seat after big blind.
     */
    func initSeatBigAndSmallBlinds() { // TODO
        seats[0].isSmallBlind = true
        seats[1].isBigBlind = true
        makePayment(seatIndex: 0, payment: 1)
        makePayment(seatIndex: 1, payment: 2)
//        let seatBigBlind = seats.first(where: { $0.isBigBlind })
//        if seatBigBlind == nil {
//            seats[0].isSmallBlind = true
//            seats[1].isBigBlind = true
//            makePayment(seatIndex: 0, payment: 1)
//            makePayment(seatIndex: 1, payment: 2)
//            return
//        }
        
        
    }
    
    func initRoundEndSeat() {
        // TODO
        seats[1].isRoundEndSeat = true
    }
    
    func findRoundEndSeatDuringGame() {
        // TODO
    }
    
    func updateRoundState(action: Action, bet: Int? = nil) {
        currentPlayerSeatTurn?.lastAction = action
        switch(action) {
        case Action.IDLE:
            // Do nothing
            break
        case Action.CHECK:
            // Do nothing
            break
        case Action.CALL:
            let difference = currentBet - currentPlayerSeatTurn!.roundPayment // TODO handle situation of no enough money
            makePayment(seatIndex: currentPlayerSeatTurn!.seatIndex, payment: difference)
            break
        case Action.BET:
            makePayment(seatIndex: currentPlayerSeatTurn!.seatIndex, payment: bet!)
            break
        case Action.FOLD:
            onFoldPressed()
            break
        }
        if let isEnd = currentPlayerSeatTurn?.isRoundEndSeat, isEnd {
            let state = gameState == GameState.IDLE ? GameState.PREFLOP :
                        gameState == GameState.PREFLOP ? GameState.FLOP :
                        gameState == GameState.FLOP ? GameState.TURN :
                        gameState == GameState.TURN ? GameState.RIVER :
                        gameState == GameState.RIVER ? GameState.REWARDS : GameState.IDLE
            changeGameState(state: state)
            return
        }
        findNextSeat()
        findRoundEndSeatDuringGame()
    }
    
    func onFoldPressed() {
        seats[currentPlayerSeatTurn!.seatIndex].player?.hand = []
        seats[currentPlayerSeatTurn!.seatIndex].roundPayment = 0
    }
    
    func findNextSeat() {
        if currentPlayerSeatTurn == nil {
            if playersCount == 2 {
                currentPlayerSeatTurn = seats[0]
            } else {
                currentPlayerSeatTurn = seats[2]
            }
            return
        }
        
        let mySeatIndex = currentPlayerSeatTurn?.seatIndex
        var currentIndex = (mySeatIndex! + 1) % seats.count  // Starting index

        while currentIndex != mySeatIndex {
            let seat = seats[currentIndex]

            if seat.isInGame() {
                currentPlayerSeatTurn = seat
                break
            }

            currentIndex = (currentIndex + 1) % seats.count  // Move to the next index
        }
    }
    
    func resetRound() {
        currentBet = 0
        currentPlayerSeatTurn = seats[0] // TODO
        for seat in seats {
            if seat.isInGame() {
                seats[seat.seatIndex].roundPayment = 0
                seats[seat.seatIndex].lastAction = Action.CHECK
            }
        }
    }
    
    func dealFlop() {
        resetRound()
        flop = []
        let burnedCard = deck?.dealCard() // burned card
        for _ in 0..<3 {
            let flopCard = deck?.dealCard()
            flop?.append(flopCard!)
        }
    }
    
    func dealTurn() {
        resetRound()
        let burnedCard = deck?.dealCard() // burned card
        turn = deck?.dealCard()!
    }
    
    func dealRiver() {
        resetRound()
        let burnedCard = deck?.dealCard() // burned card
        river = deck?.dealCard()!
    }
    
    func determineWinners() {
        var handsMap: [Int: (hand: [Card], description: String)] = [:]
        for seat in seats {
            if seat.isInGame() {
                let playerHand = seat.player?.hand
                let playerStrongestHand = GameValidator.findStrongestHand(flop: flop!, turn: turn!, river: river!, hand: playerHand!)
                print("Player \(seat.player!.name) Strongest Hand: \(playerStrongestHand)")
                handsMap[seat.seatIndex] = (playerStrongestHand)
            }
        }
        let winners = GameValidator.determineWinners(handsMap)
        if winners.count == 1 {
            let winner = winners[0]
            let name = seats[winner.seatIndex].player?.name ?? ""
            winnerDetails = "Winner: \(name)!"
        } else {
            winnerDetails += "Winners:"
            for winner in winners {
                let name = seats[winner.seatIndex].player?.name ?? ""
                winnerDetails += "\n\(name)"
            }
            winnerDetails += " !"
        }
        let splitMoney = pot / winners.count
        for winner in winners {
            seats[winner.seatIndex].player?.chips += splitMoney
        }
      }
    
    func makePayment(seatIndex: Int, payment: Int) {
        if seatIndex < seats.count {
            pot += payment

            seats[seatIndex].player?.chips -= payment
            seats[seatIndex].roundPayment += payment
            seats[seatIndex].totalPayment += payment
        }
    }
}
