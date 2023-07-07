//
//  Action.swift
//  ChaPoker
//
//  Created by Elad Sabag on 07/07/2023.
//

import Foundation

enum Action: String, Codable {
    case CHECK = "CHECK"
    case CALL = "CALL"
    case BET = "BET"
    case FOLD = "FOLD"
}
