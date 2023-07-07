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
    
    private init() {
        let tables = initTables()
    }
    
    private func initTables() -> [Table] {
        var tables: [Table] = []
        
        for i in 1...2 {
            let tableID = "table_\(i)"
            let gameType = i % 2 == 0 ? "Omaha" : "Texas"
            let numberOfPlayers = 5
            
            let table = Table(tableID: tableID, gameType: gameType, maxPlayers: numberOfPlayers, bigBlind: 2)
            
            tables.append(table)
            
            addTableToFirebase(table: table) { result in
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
        
        return tables
    }
    
    func addTableToFirebase(table: Table, completion: @escaping (Result<Void, Error>) -> Void) {
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
                            completion(.success(()))
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

    
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken(),
           let userId = UserDefaultsManager.shared.getUserID() {
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
    
    func fetchTables(completion: @escaping (Result<[Table]?, Error>) -> Void) {
        if let authToken = UserDefaultsManager.shared.getAuthToken() {
            let url = URL(string: "\(NetworkManager.baseUrl)/tables.json?auth=\(authToken)")!
            
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
                    let tables = try decoder.decode([String: Table].self, from: data).map { $0.value }
                    completion(.success(tables))
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
                            completion(.success(()))
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
}

enum NetworkError: Error {
    case invalidData
    case statusCode(Int)
}
