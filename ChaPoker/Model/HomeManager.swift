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
                print("Response: \(data)")
                self.tables = data
                self.delegate?.onTablesUpdated()
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
            }
        }
    }

    func observeTables() {
        tablesReference.observe(.value) { snapshot in
            guard let tablesData = snapshot.value as? [String: Any] else {
                // Handle error or empty data
                return
            }

            do {
                let decoder = JSONDecoder()
                let tablesJSONData = try JSONSerialization.data(withJSONObject: tablesData, options: [])

                // Decode the tables data into an array of Table objects
                let updatedTables = try decoder.decode([String: Table].self, from: tablesJSONData)
                    .map { $0.value }

                // Update the local tables property
                self.tables = updatedTables
                self.delegate?.onTablesUpdated()
            } catch {
                // Handle error during decoding
                print("Error decoding tables data:", error)
            }
        }
    }
    
    func joinTable(table: Table, user: User) {
        if table.players?.count == 5 ||
            table.players?.contains(where: { $0.userId == user.userId }) == true {
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
