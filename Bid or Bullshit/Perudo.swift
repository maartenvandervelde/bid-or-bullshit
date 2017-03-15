//
//  Perudo.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation

class Perudo {
    
    static func isBidCorrect(bid: Bid, player1dice: [Int], player2dice: [Int]) -> Bool {
        let allDice = player1dice + player2dice
        var count = 0
        for pips in allDice {
            if (pips == bid.numberOfPips) {
                count += 1
            }
        }
        return count >= bid.numberOfDice
    }
    
    
}

struct Bid {
    var numberOfDice: Int = 1
    var numberOfPips: Int = 1
    
    func repr() -> String {
        return "\(numberOfDice) dice with \(numberOfPips) pips"
    }
    
    func printBid() {
        print("Bid: \(numberOfDice) dice with \(numberOfPips) pips")
    }
}
