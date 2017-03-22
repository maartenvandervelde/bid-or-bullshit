//
//  Perudo.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation

class Perudo {
    
    
    static func isBidLegal(previous: Bid, new: Bid) -> Bool {
        
        // new bid increments number of dice by 1
        if (new.numberOfDice == previous.numberOfDice + 1) {
            // new bid decrements or increments number of pips by 1, or keeps it the same
            if (new.numberOfPips == previous.numberOfPips - 1 || new.numberOfPips == previous.numberOfPips || new.numberOfPips == previous.numberOfPips + 1) {
                return true
            }
        }
        
        // new bid increments number of pips by 1, number of dice stays the same
        if (new.numberOfPips == previous.numberOfPips + 1 && new.numberOfDice == previous.numberOfDice) {
            return true
        }
        
        return false
    }
    
    
    
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
