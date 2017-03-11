//
//  Player.swift
//  Bid or Bullshit
//
//  Created by M.A. van der Velde on 07/03/17.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation


class Player {
    
    var playerHasLost: Bool = false
    
    var diceList = Array(repeating: 0, count: 5) {
        didSet {
            if (diceList.count == 0) {
                playerHasLost = true
            }
        }
    }
    
    
    /// Assign a random value ranging from 1 to 6 to each of the dice in a player's diceList.
    func rollDice() {
        diceList = diceList.map {_ in Int(arc4random_uniform(6)) + 1}
    }
    
    /// Remove one dice from the player's diceList.
    func discardDice() {
        diceList.removeLast()
    }
    
    
    
    
    init() {
        rollDice()
    }
    
}
