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
    
    private var latestBid: Bid?
    
    func makeOpeningBid() {
        
    }
    
    func respondToBid(bid: Bid) -> Bid? {
        // for now we just return a bid that increases the number of dice by 1.
        latestBid = Bid(numberOfDice: bid.numberOfDice + 1, numberOfPips: bid.numberOfPips)
        return latestBid
    }
    
    func speak(gamestate: GameState) -> String {
        // These are some canned responses that the model says every time the game state changes.
        // It returns a different string depending on the game state (this can be expanded further if needed).
        switch gamestate {
        case .GameStart:
            return "This is the model speaking at the start of the game."
        case .ModelOpeningBid:
            return "I'm making an opening bid."
        case .PlayerOpeningBid:
            return "The player is making an opening bid."
        case .ModelResponse:
            return "Let me think about it..."
        case .PlayerResponse:
            return "I bid \(latestBid!.repr())."
        case .ModelCallsBullshit:
            return "I don't believe you."
        case .PlayerCallsBullshit:
            return "You don't believe me."
        case .ModelWinsRound:
            return "I have won."
        case .PlayerWinsRound:
            return "You win this time."
        case .ModelWinsGame:
            return "I have won the game"
        case .PlayerWinsGame:
            return "You have won the game."
    }

    }
}
