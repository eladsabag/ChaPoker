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
        case .two:
             return 2
         case .three:
             return 3
         case .four:
             return 4
         case .five:
             return 5
         case .six:
             return 6
         case .seven:
             return 7
         case .eight:
             return 8
         case .nine:
             return 9
         case .ten:
             return 10
         case .jack:
             return 11
         case .queen:
             return 12
         case .king:
             return 13
        case .ace:
            return 14
        }
    }
}
