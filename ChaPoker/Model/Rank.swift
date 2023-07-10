//
//  Rank.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

enum Rank: String, CaseIterable, Codable {
    case ace = "ace"
    case two = "two"
    case three = "three"
    case four = "four"
    case five = "five"
    case six = "six"
    case seven = "seven"
    case eight = "eight"
    case nine = "nine"
    case ten = "ten"
    case jack = "jack"
    case queen = "queen"
    case king = "king"
    
    var value: Int {
        switch self {
//        case .ace:
//            return 1
        case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten:
            return Int(self.rawValue)!
        case .jack:
            return 11
        case .queen:
            return 12
        case .king:
            return 13
        case .ace:
            return 14
//        case .jack, .queen, .king:
//            return 10
        }
    }
}
