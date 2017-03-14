//
//  ModelPlayer.swift
//  Bid or Bullshit
//
//  Created by M.A. van der Velde on 07/03/17.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation


class ModelPlayer: Player {
    
    // instantiation of and interaction with act-r model goes here.
    
    
    func makeOpeningBid() {
        
    }
    
    func respondToBid(bid: Bid) {
        
    }
    
    func speak(gamestate: GameState) -> String {
        // The model says something every time the game state changes.
        // It returns a different string depending on the game state (this can be expanded further if needed).
        switch gamestate {
        case .GameStart:
            return "This is the model speaking at the start of the game."
        case .ModelOpeningBid:
            return "I'm making an opening bid."
        case .PlayerOpeningBid:
            return "The player is making an opening bid."
        case .ModelResponse:
            return "I'm responding to the player's bid."
        case .PlayerResponse:
            return "The player is responding to my bid."
        case .Results:
            return "The results are being shown."
        case .GameOver:
            return "One of us has won."
        }
    }

    
}
