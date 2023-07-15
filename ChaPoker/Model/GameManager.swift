//
//  GameManager.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation
import FirebaseDatabase

protocol GameManagerDelegate {
    func onTableUpdated()
    func onUserLeavedTable()
}

class GameManager {
    var delegate: GameManagerDelegate?
    var table: Table
    var user: User
    var tableReference: DatabaseReference!
    let client = NetworkManager.shared

    init(table: Table, user: User) {
        self.table = table
        self.user = user
    }
    
    func observeTable() {
        client.observeTable(tableId: table.tableID) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.table = data
                self.delegate?.onTableUpdated()
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
    }

    // TODO handle this states
    func observeAllPlayersConnectivity(userId: String) {
        client.observeUserConnectivity(userId: userId) { isConnected in
            if isConnected {
                print("User \(userId) is connected")
            } else {
                print("User \(userId) is disconnected")
            }
        }
    }
    
    func leaveTable() {
        if table.playersCount == 0 {
            return
        }
        table.removePlayer(user)
        client.updateTable(table: table) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("leaveTable Response: \(data)")
                self.delegate?.onUserLeavedTable()
            case .failure(let error):
                // Handle error
                print("leaveTable Error: \(error)")
            }
        }
        
    }
    
    func updateTable() {
        client.updateTable(table: table) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.delegate?.onTableUpdated()
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
    }
    
    func startGameIfNotPlaying() {
        if table.gameState == GameState.IDLE && table.playersCount >= 2 {
            print("start game if not playing")
            table.startGame()
            updateTable()
        }
    }
    
    func isMyTurn() -> Bool {
        if let currentPlayer = table.currentPlayerSeatTurn?.player {
            return user.userId == currentPlayer.userId
        }
        return false
    }
    
    func isSomeoneMadeBet() -> Bool {
        if table.currentBet > 0 {
            return true
        }
        return false
    }
    
    func isPayed() -> Bool {
        if table.currentPlayerSeatTurn?.roundPayment == table.currentBet { // TODO handle half payment(ALLIN situation)
            return true
        }
        return false
    }
    
    func isInGame() -> Bool {
        if let seat = table.seats.first(where: { $0.isMySeat(userId: user.userId) }) {
            return seat.isInGame()
        }
        return false
    }
    
    func isGameOver() -> Bool {
        return table.gameState != GameState.IDLE && table.playersCount <= 1
    }
    
    func updateRoundState(action: Action, bet: Int? = nil) {
        table.updateRoundState(action: action, bet: bet)
        updateTable()
        updateUserChips()
    }
    
    func updateUserChips() {
        let userId = user.userId
        let seat = table.seats.first(where: { $0.isInGame() && $0.player?.userId == userId })
        if seat != nil {
            client.updateUserChips(userId: userId, newChipsValue: (seat?.player!.chips)!) { result in
                switch result {
                case .success(let data):
                    // Handle successful response
                    print("Response: \(data)")
                case .failure(let error):
                    // Handle error
                    print("Error: \(error)")
                }
            }
        }
    }
}
