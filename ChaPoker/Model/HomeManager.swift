//
//  HomeManager.swift
//  ChaPoker
//
//  Created by Elad Sabag on 01/07/2023.
//
import FirebaseDatabase

protocol HomeManagerDelegate {
    func onTablesUpdated()
    func onUserJoinedTable(table: Table)
}

class HomeManager {
    var delegate: HomeManagerDelegate?
    var user: User?
    var tables: [Table]?
    var tablesReference: DatabaseReference!
    let client = NetworkManager.shared

    init(user: User? = nil, tables: [Table]? = nil) {
        self.user = user
        self.tables = tables

        // Set up the Firebase database reference for the tables
        tablesReference = Database.database().reference().child("tables")
    }
    
    func fetchTables() {
        client.fetchTables { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(String(describing: data))")
                self.tables = data
                self.delegate?.onTablesUpdated()
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
    }

    func observeTables() {
        client.observeTables { [self] result in
            switch result {
                
            case .success(let data):
                print("Response: \(String(describing: data))")

                // Update the local tables property
                self.tables = data
                self.delegate?.onTablesUpdated()
                break
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func joinTable(table: Table, user: User) {
        if table.playersCount == 5 {
            return
        }
        let index = tables?.firstIndex(where: { $0.tableID == table.tableID })
        tables![index!].addPlayer(user)
        client.updateTable(table: tables![index!]) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.delegate?.onUserJoinedTable(table: self.tables![index!])
                
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
    }
}
