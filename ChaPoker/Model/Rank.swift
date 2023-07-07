//
//  Rank.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import Foundation

enum Rank: String, CaseIterable, Codable {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    
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
