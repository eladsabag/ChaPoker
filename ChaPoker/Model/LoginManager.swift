//
//  LoginManager.swift
//  ChaPoker
//
//  Created by Elad Sabag on 01/07/2023.
//

import Foundation

protocol LoginManagerDelegate {
    func onAddUser(isSuccess: Bool)
    func onFetchUser(isSuccess: Bool)
}

class LoginManager {
    var delegate: LoginManagerDelegate?
    var user: User?
    let client = NetworkManager.shared
    
    func addUser() {
        client.addUserToFirebase(user: self.user!) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.delegate?.onAddUser(isSuccess: true)
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
                self.delegate?.onAddUser(isSuccess: false)
            }
        }
    }
    
    func getUser(userId: String) {
        client.fetchCurrentUser(userId: userId) { result in
            switch result {
            case .success(let data):
                // Handle successful response
                print("Response: \(data)")
                self.user = data
                self.delegate?.onFetchUser(isSuccess: true)
            case .failure(let error):
                // Handle error
                print("Error: \(error)")
                self.delegate?.onFetchUser(isSuccess: false)
            }
        }
    }
}
