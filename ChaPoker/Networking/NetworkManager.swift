//
//  NetworkManager.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class NetworkManager {
    static let shared = NetworkManager()
    static let baseUrl = "https://chapoker-ed624-default-rtdb.firebaseio.com/"
    var tablesReference: DatabaseReference!
    var usersReference: DatabaseReference!

    private init() {
        tablesReference = Database.database().reference().child("tables")
        usersReference = Database.database().reference().child("users")
        initTables()
    }
    
    func initTables() {
        // Initialize two Table instances
        let table1 = Table(tableID: "table1", gameType: "Texas Holdem", maxPlayers: 5, bigBlind: 2)
        let table2 = Table(tableID: "table2", gameType: "Chap Pineapple", maxPlayers: 5, bigBlind: 2)
        let table3 = Table(tableID: "table3", gameType: "Chap Choco", maxPlayers: 5, bigBlind: 2)

        // Create an array of tables
        let tables: [Table] = [table1, table2, table3]

        // Post the tables to Firebase
        for table in tables {
            addTableToFirebase(table: table) { result in
                switch result {
                case .success:
                    print("Tables posted successfully!")
                case .failure(let error):
                    print("Failed to post tables: \(error)")
                }
            }
        }
    }
    
    func addTableToFirebase(table: Table, completion: @escaping (Result<Data, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() { // Retrieve the Firebase Authentication user ID
            let url = URL(string: "\(NetworkManager.baseUrl)/tables/\(table.tableID).json?auth=\(authToken)")!

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"

            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(table)

                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        if (200..<300).contains(httpResponse.statusCode) {
                            if let data = data {
                                completion(.success(data))
                            } else {
                                completion(.failure(NetworkError.invalidData))
                            }
                        } else {
                            completion(.failure(NetworkError.statusCode(httpResponse.statusCode)))
                        }
                    }
                }

                task.resume()
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchTables(completion: @escaping (Result<[Table], Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() {
            let url = URL(string: "\(NetworkManager.baseUrl)/tables.json?auth=\(authToken)")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                guard let jsonData = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let tables = try decoder.decode([String: Table].self, from: jsonData)
                        .map { $0.value }
                        .sorted { $0.tableID.localizedStandardCompare($1.tableID) == .orderedAscending }
                    completion(.success(tables))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }

    
    func addUserToFirebase(user: User, completion: @escaping (Result<Data, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() { // Retrieve the Firebase Authentication user ID
            let url = URL(string: "\(NetworkManager.baseUrl)/users/\(user.userId).json?auth=\(authToken)")!

            var request = URLRequest(url: url)
            request.httpMethod = "PUT" 

            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(user)

                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        if (200..<300).contains(httpResponse.statusCode) {
                            if let data = data {
                                completion(.success(data))
                            } else {
                                completion(.failure(NetworkError.invalidData))
                            }
                        } else {
                            completion(.failure(NetworkError.statusCode(httpResponse.statusCode)))
                        }
                    }
                }

                task.resume()
            } catch {
                completion(.failure(error))
            }
        }
    }

    
    func fetchCurrentUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() {
            let url = URL(string: "\(NetworkManager.baseUrl)/users/\(userId).json?auth=\(authToken)")!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.invalidData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }

    func updateTable(table: Table, completion: @escaping (Result<Void, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() {
            let url = URL(string: "\(NetworkManager.baseUrl)/tables/\(table.tableID).json?auth=\(authToken)")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(table)
                
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if (200..<300).contains(httpResponse.statusCode) {
                            print("updateTable success")
                            completion(.success(()))
                        } else {
                            print("updateTable failure")
                            completion(.failure(NetworkError.statusCode(httpResponse.statusCode)))
                        }
                    }
                }
                
                task.resume()
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func observeTables(completion: @escaping (Result<[Table], Error>) -> Void) {
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
                    .sorted { $0.tableID.localizedStandardCompare($1.tableID) == .orderedAscending }
                
                completion(.success(updatedTables))
            } catch {
                // Handle error during decoding
                print("Error decoding tables data:", error)
                completion(.failure(error))
            }
        }
    }
    
    func observeTable(tableId: String, completion: @escaping (Result<Table, Error>) -> Void) {
        tablesReference.child(tableId).observe(.value) { snapshot in
            guard let tableData = snapshot.value as? [String: Any] else {
                // Handle error or empty data
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tableJSONData = try JSONSerialization.data(withJSONObject: tableData, options: [])
                let updatedTable = try decoder.decode(Table.self, from: tableJSONData)
                
                completion(.success(updatedTable))
            } catch {
                // Handle error during decoding
                print("Error decoding table data:", error)
                completion(.failure(error))
            }
        }
    }
    
    func observeUserConnectivity(userId: String, completion: @escaping (Bool) -> Void) {
        let userLastActiveRef = Database.database().reference().child("users/\(userId)/lastActive")

        userLastActiveRef.onDisconnectSetValue(ServerValue.timestamp())

        userLastActiveRef.observe(.value) { (snapshot, _) in
            if let lastActiveTimestamp = snapshot.value as? TimeInterval {
                // Perform actions based on the user's last active timestamp
                let currentDate = Date()
                let lastActiveDate = Date(timeIntervalSince1970: lastActiveTimestamp)
                
                // Compare the current date with the last active date to determine connectivity status
                let isConnected = currentDate.timeIntervalSince(lastActiveDate) < 10 // Example: consider connected if within 10 seconds
                completion(isConnected)
            } else {
                // User's last active timestamp is missing or invalid
                // Return false for an unknown connectivity status
                completion(false)
            }
        }
    }
    
    func updateUserChips(userId: String, newChipsValue: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        let userRef = usersReference.child(userId)

        userRef.updateChildValues(["chips": newChipsValue]) { (error, _) in
            if let error = error {
                completion(.failure(error))
            } else {
                // Fetch the updated data to provide it in the completion block.
                userRef.observeSingleEvent(of: .value) { (snapshot) in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: snapshot.value as Any, options: [])
                        completion(.success(jsonData))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case invalidUrl
    case noData
    case invalidData
    case statusCode(Int)
}
