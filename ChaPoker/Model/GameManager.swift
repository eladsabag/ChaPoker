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
    var table: Table?
    var user: User?
    var tableReference: DatabaseReference!
    let client = NetworkManager.shared

    init(table: Table? = nil, user: User? = nil) {
        self.table = table
        self.user = user
        
        // Set up the Firebase database reference for the tables
        tableReference = Database.database().reference().child("tables").child(table!.tableID)
    }
    
    func observeTable() {
        tableReference.observe(.value) { snapshot in
            guard snapshot.exists(), let tableData = snapshot.value as? [String: Any] else {
                // Handle error or empty data
                return
            }

            do {
                let decoder = JSONDecoder()
                let tableJSONData = try JSONSerialization.data(withJSONObject: tableData, options: [])

                // Decode the table data into a Table object
                let updatedTable = try decoder.decode(Table.self, from: tableJSONData)

                // Update the local table property
                self.table = updatedTable
                self.delegate?.onTableUpdated()
            } catch {
                // Handle error during decoding
                print("Error decoding table data:", error)
            }
        }
    }
    
    func leaveTable() {
        if table?.players?.count == 0 ||
            table?.players?.contains(where: { $0.userId == user!.userId }) == false {
            return
        }
        table?.removePlayer(user!)
        client.updateTable(table: table!) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.delegate?.onUserLeavedTable()
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
        
    }
    
    func updateTable() {
        client.updateTable(table: table!) { result in
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
        if table?.gameState == GameState.IDLE {
            table?.startGame()
        }
    }
    
    func isMyTurn(userId: String) -> Bool {
        if let currentPlayer = table?.currentPlayerTurn {
            return userId == currentPlayer.userId
        }
        return false
    }
    
    func isSomeoneMadeBet() -> Bool {
        if table!.currentBet > 0 {
            return true
        }
        return false
    }
    
    func updateAction(userId: String, action: Action, bet: Int? = nil) {
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
    }
}
