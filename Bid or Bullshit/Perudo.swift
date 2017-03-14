//
//  Perudo.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation

class Perudo {
    
}

struct Bid {
    var numberOfDice: Int = 1
    var numberOfPips: Int = 1
    
    
    func printBid() {
        print("Bid: \(numberOfDice) dice with \(numberOfPips) pips")
    }
}
