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
    //var dm  = Declarative()
    
    private var latestBid: Bid?
    
    func makeOpeningBid() {
 
        var myDice = self.diceList
        //var myTopDice = getMyTopDice(myDice)
        /*var opponentDice = getOpponentDice(DM, myDice)
        var previousOpeningBid = getPreviousOpeningBid(DM, myTopDice, opponentDice)

        if previousOpeningBid != nil{//retrieval succes
            openingBid = previousOpeningBid
        } else {//retrieval failure
            openingBid = makeDefaultOpeningBid(myDice, opponentDice)
        }

        return openingBid*/
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

    /*func getMyTopDice(ownDice){
        //Choose pip with highest number of dice
        var
        for(index,Dice) in ownDice{
            
        }
        var topDice

        

        //if pips share highest number of dice, choose highest pip

        return topDice
    }*/
    
    /*func getOpponentDice(DM, ownDice){
        var opponentDiceNumber = retrieveChunk(DM,type=opponentDiceNum)

        if opponentDiceNumber == nil{//retrieval failure
            opponentDiceNumber = length(ownDice)
        }

        return opponentDiceNumber
    }

    func getPreviousOpeningBid(DM, ownDice, opponentDice){
        var openingBid = nil
        openingBid = retrieveChunk(DM,type=openingbid, ownDice, opponentDice)

        return openingBid
    }

    func getPreviousOpponentBidResponse(DM, ownDice, opponentDice, opponentBid){
        var response = nil
        response = retrieveChunk(DM,type=bidresponse, ownDice, opponentDice, opponentBid)

        return response
    }

    func makeDefaultOpeningBid(ownDice, opponentDice){
        var openingBid = [:]
        var extraDice = opponentDice/6

        //openingBid = owndice + extraDice

        return openingBid
    }

    func makeDefaultReponse(ownDice, opponentDice, opponentBid){

        var result = something()//subtract target dice from opponents bid	

        if (result/opponentDice<1/6){//if below pip probability

        } else {
            makeCounterBid(myDice, opponentBid)
        }
    }

    func evaluateBid(opponentBid, myDice){
        var opponentDice = getOpponentDice(DM, type=opponentDiceNum, myDice)
            
        var response = getPreviousOpponentBidResponse(DM, myDice, opponentDiceNum, opponentBid)

        if (response=!NULL){//retrieval succes
            if(response=="bullshit"){
                callBullshit()
            } else {
                makeCounterBid(myDice, opponentBid)
            }
        } else {//retrieval failure
            makeDefaultResponse(myDice, opponentDice, opponentBid)
        }
    }

    func makeCounterBid(myDice, opponentBid){

    }*/
}
