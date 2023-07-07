//
//  UserDefaultsManager.swift
//  ChaPoker
//
//  Created by Elad Sabag on 29/06/2023.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let loggedInKey = "isLoggedIn"
    private let authTokenKey = "authTokenKey"
    private let userIdKey = "userIdKey"

    private init() {}

    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: loggedInKey)
    }

    func setLoggedIn(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: loggedInKey)
    }
    
    func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: authTokenKey)
    }

    func setAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: authTokenKey)
    }
    
    func getUserID() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }

    func setUserID(_ token: String) {
        UserDefaults.standard.set(token, forKey: userIdKey)
    }
}
