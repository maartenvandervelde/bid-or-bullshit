//
//  Perudo.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation


/**
 Struct that contains the information necessary to represent a player's bid.
 */
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


class Perudo {
    
    /**
     Checks whether a given bid is a legal response to a previous bid. Returns True if it is, False otherwise.
     Parameters:
        previous: Bid       -       A previously made bid.
        new: Bid            -       The bid that is to be evaluated.
    */
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
    
    
    /**
     Checks whether a given bid is supported by the dice that both players have. Returns True if it is, otherwise False.
     Parameters:
        bid: Bid            -       The bid that is to be evaluated.
        player1dice: [Int]  -       Integer array of the pip values of the first player's dice.
        player2dice: [Int]  -       Integer array of the pip values of the second player's dice.
    */
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

