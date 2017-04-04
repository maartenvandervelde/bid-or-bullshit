//
//  ModelPlayer.swift
//  Bid or Bullshit
//
//  Created by M.A. van der Velde on 07/03/17.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import Foundation

class ModelPlayer: Player {
    
    var rememberMemory = false
    
    var character: OpponentCharacter?
    
    init(character: OpponentCharacter) {
        self.character = character
        
    }
    
    let hookPhrases: [GameState:String] = [
        .ModelOpeningBid: "I'll show you how it's done!",
        .PlayerOpeningBid: "Let's see what you're made of!",
        .ModelResponse: "Let's see...",
        .PlayerResponse: "What do you make of my bid?!",
        .ModelCallsBullshit: "Liar! Are you trying to be a grown-up?!",
        .PlayerCallsBullshit: "You think I'm lying?!",
        .ModelWinsRound: "If I were you, I'd give up.",
        .PlayerWinsRound: "Arrrr! How dare you?!",
        .ModelWinsGame: "You're a tragedy! No happy thought left for you. I win!",
        .PlayerWinsGame: "No! My life is over. Let the crocodile come get me."
    ]
    
    let davyPhrases: [GameState:String] = [
        .ModelOpeningBid: "You can't beat me! You'll never get the key.",
        .PlayerOpeningBid: "Come to join my crew? Let us play!",
        .ModelResponse: "Let me contemplate this...",
        .PlayerResponse: "Let me hear your judgement on my bid.",
        .ModelCallsBullshit: "You liar!",
        .PlayerCallsBullshit: "Think you can outwit me?!",
        .ModelWinsRound: "Lookee here. A lost bird that never learned to fly.",
        .PlayerWinsRound: "Don't you want to spend eternity on this ship?",
        .ModelWinsGame: "Life is cruel! But not to me today!",
        .PlayerWinsGame: "When next you sail, we'll meet again."
    ]
    
    let chingPhrases: [GameState:String] = [
        .ModelOpeningBid: "Give up now, you'll never win from me!",
        .PlayerOpeningBid: "Do you dare to challenge my Red Flag Fleet?",
        .ModelResponse: "What is your strategy...?",
        .PlayerResponse: "Try and oppose me!",
        .ModelCallsBullshit: "Victory cannot escape me!",
        .PlayerCallsBullshit: "You believe me a liar?",
        .ModelWinsRound: "You broke the code of honor! You're walking the plank!",
        .PlayerWinsRound: "You won this battle, but you will not win the war!",
        .ModelWinsGame: "You too have suffered a humiliating defeat at my hands!",
        .PlayerWinsGame: "Okay, I'll retire, but I'll keep the treasure I won!"
    ]
    
    // instantiation of and interaction with act-r model
    
    var time: Double = 0
    var dm = Declarative()
    var chunkIdCounterOpponentDiceNum = 0
    var chunkIdCounterOpeningBid = 0
    var chunkIdCounterOpponentBid = 0
    var running = false
    var trace: String = "" {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TraceChanged"), object: nil)
        }
    }
    var waitingForAction: Bool = false {
        didSet {
            if waitingForAction == true {
                print("Posted Action notification")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "Action"), object: nil)
            }
        }
    }
    var modelText: String = ""
    
    private var latestBid: Bid?
    
    func speak(gamestate: GameState) -> String {
        // These are some canned responses that the model says every time the game state changes.
        // It returns a different string depending on the game state (this can be expanded further if needed).
        
        switch(character!.name) {
        case "Captain Hook":
            return hookPhrases[gamestate]!
        case "Davy Jones":
            return davyPhrases[gamestate]!
        case "Ching Shih":
            return chingPhrases[gamestate]!
        default:
            return ""
        }
        
        /*
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
         */
    }
    
    func makeOpeningBid() -> Bid {
        
        let myDice = self.diceList //Assume format is [pips, pips, pips, ...]
        //print("myDice: ", myDice)
        let (myTopDice, myTurfedDice) = getMyTopDice(ownDice: myDice) //[dice, pips][dice,dice,dice,dice,dice,dice]
        //print("myTurfedDice: ", myTurfedDice)
        //print("myTopDice: ", myTopDice)
        let opponentDice = getOpponentDice(ownDice:myDice)
        //print("opponentDice: ", opponentDice)
        let openingBid = getPreviousOpeningBid(ownDice: myTurfedDice, topDice: myTopDice, opponentDice: opponentDice)
        //print("openingBid: ", openingBid)
        
        latestBid = Bid(numberOfDice: openingBid[0], numberOfPips: openingBid[1])
        
        print("myTurfedDice: ", myTurfedDice)
        print("opponentDice: ", opponentDice)
        print("openingBid: ", openingBid)
        
        return latestBid!
    }
    
    func respondToBid(bid: Bid) -> Bid? {
        let myDice = self.diceList
        let opponentBid:[Int] = [bid.numberOfDice, bid.numberOfPips]
        let (myTopDice, myTurfedDice) = getMyTopDice(ownDice: myDice)
        let opponentDice = getOpponentDice(ownDice:myDice)
        var response: [Int]?
        response = getPreviousOpponentBidResponse(ownDice: myTurfedDice, opponentDice: opponentDice, opponentBid: opponentBid)
        
        if response!.count > 1{
            latestBid = Bid(numberOfDice: (response?[0])!, numberOfPips: (response?[1])!)
        }
        else{
            //GameState.ModelCallsBullshit
            
            // When the model wants to call bullshit, it does so by not returning anything
            return nil
        }
        
        print("myTurfedDice: ", myTurfedDice)
        print("opponentBid: ", opponentBid)
        print("opponentDice: ", opponentDice)
        print("response: ", response!)
        
        return latestBid
    }
    
    func getMyTopDice(ownDice: Array<Int>) -> (Array<Int>, Array<Int>){
        //Choose pip with highest number of dice
        var dice: [Int] = [0,0,0,0,0,0]
        for die in ownDice{
            dice[die-1] = dice[die-1] + 1
        }
        let maxDice = dice.max()
        var maxPips: Int = -1
        
        //if pips share highest number of dice, choose highest pip
        for pips in 0 ..< dice.count{
            if dice[pips]==maxDice {
                maxPips = pips+1
            }
        }
        let topDice: [Int] = [maxDice!,maxPips] //[0]:num dice, [1]:num pips
        
        return (topDice, dice)
    }
    
    func getOpponentDice(ownDice: Array<Int>) -> Int{
        let slots: Array<String> = ["type"]
        let values: Array<Value> = [Value.Text("opponentDiceNum")]
        let (latency, retrievedChunk) = dm.retrieve(slots: slots, values: values)
        
        var opponentDiceNumber: Int = -1
        
        if retrievedChunk == nil{//retrieval failure
            print("I do not remember the number of my opponents dice, lets assumme they have the same as me")
            opponentDiceNumber = ownDice.count
        } else {
            print("I remember the number of my opponents dice")
            print(retrievedChunk!.description)
            print("Latency opponentDice", latency)
            opponentDiceNumber = Int((retrievedChunk!.slotvals["opponentDiceNum"]?.description)!)!
            //add encounter of chunk
            dm.addToDM(retrievedChunk!)
        }
        
        return opponentDiceNumber
    }
    
    func getPreviousOpeningBid(ownDice: Array<Int>, topDice: Array<Int>,  opponentDice: Int) -> Array<Int>{
        var openingBid: Array<Int> = [0,0]
        let slots: Array<String> = ["type","opponentDiceNum","myDice"]
        let values: Array<Value> = [Value.Text("openingBid"),Value.NumberI(opponentDice),Value.Array(topDice)]
        let (latency, retrievedChunk) = dm.retrieve(slots: slots, values: values)
        
        if retrievedChunk == nil{//retrieval failure
            print("I do not remember a previous openingbid, lets make a standard bid")
            openingBid = makeDefaultOpeningBid(topDice: topDice, opponentDice: opponentDice)
        } else {//retrieval succes
            print("I remember a previous openingbid")
            print(retrievedChunk!.description)
            print("Latency openingbid", latency)
            var retrievedBid = retrievedChunk!.slotvals["myBid"]!.description
            retrievedBid = retrievedBid.replacingOccurrences(of: ",", with: "",options: .regularExpression)
            retrievedBid = retrievedBid.replacingOccurrences(of: "\\[", with: "",options: .regularExpression)
            retrievedBid = retrievedBid.replacingOccurrences(of: "]", with: "",options: .regularExpression)
            let retrievedBidArray = retrievedBid.components(separatedBy: " ")
            openingBid = retrievedBidArray.map { Int($0)!}
            //add encounter of chunk
            dm.addToDM(retrievedChunk!)
        }
        
        return openingBid
    }
    
    func makeDefaultOpeningBid(topDice: Array<Int>, opponentDice: Int) -> Array<Int>{
        let extraDice: Int = Int(floor(Double(opponentDice/6)))
        print("diceList: ", topDice)
        print("opponentDiceNum: ", opponentDice)
        print("extraDice: ", extraDice)
        let openingBid: [Int] = [topDice[0]+extraDice,topDice[1]] //[0]:num dice, [1]:num pips
        
        //create new chunk and add to dm
        print("Adding new opening bid chunk")
        let chunk = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: opponentDice, myDice: topDice, myBid: openingBid)
        dm.addToDM(chunk)
        
        return openingBid
    }
    
    func getPreviousOpponentBidResponse(ownDice: Array<Int>, opponentDice: Int, opponentBid: Array<Int>) -> Array<Int>{
        var response: [Int]?
        response = nil
        let slots: Array<String> = ["type","opponentDiceNum","myDice", "opponentBid"]
        let values: Array<Value> = [Value.Text("opponentBid"),Value.NumberI(opponentDice),Value.Array(ownDice),Value.Array(opponentBid)]
        let (latency, retrievedChunk) = dm.retrieve(slots: slots, values: values)
        
        if retrievedChunk == nil{//retrieval failure
            print("I do not remember a previous response to a similar bid, lets make a standard response")//can be bullshit
            response = makeDefaultResponse(ownDice: ownDice, opponentDice: opponentDice, opponentBid: opponentBid)
        } else {//retrieval succes
            print("I remember a previous response to a similar bid")
            print(retrievedChunk!.description)
            print("Latency previousresponse", latency)
            let retrievedResult = Int((retrievedChunk!.slotvals["result"]?.description)!)!
            
            if(retrievedResult==1){
                response = makeCounterBid(myDice: ownDice, opponentBid: opponentBid)
            } else {
                response = [0]
            }
            //add encounter of chunk
            dm.addToDM(retrievedChunk!)
            
        }
        
        return response!
    }
    
    func makeDefaultResponse(ownDice: Array<Int>, opponentDice: Int, opponentBid: Array<Int>) -> Array<Int>{
        var response: [Int]?
        response = [0] //response can either hold 0[reject] or counterbid[dice, pips]
        
        print("dicelist: ", ownDice)
        let matchedDice = ownDice[opponentBid[1]-1]
        print("matchedDice: ", matchedDice)
        let remainder = opponentBid[0] - matchedDice
        print("remainder/opponentDice: ", Double(Double(remainder)/Double(opponentDice)))
        
        //if below pip probability or not
        if (Double(Double(remainder)/Double(opponentDice)) > Double(1.0/4.0)){
            print("I want to reject this")
            //leave response as '0'
            
            //create new chunk and add to dm
            print("Adding new opponent bid chunk")
            let chunk = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: opponentDice, myDice: ownDice, opponentBid: opponentBid, result: 0)//0: Bullshit & 1: Accept
            dm.addToDM(chunk)
            
        } else {
            //randomly reject offer
            let choice = arc4random_uniform(10)
            if(choice==0){
                print("I randomly want to reject this")
                
                //create new chunk and add to dm
                print("Adding new opponent bid chunk")
                let chunk = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: opponentDice, myDice: ownDice, opponentBid: opponentBid, result: 0)//0: Bullshit & 1: Accept
                dm.addToDM(chunk)
                
            } else {
                print("I want to make a counter offer")
                response = makeCounterBid(myDice: ownDice, opponentBid: opponentBid)
                print("Response: ", response!)
                
                //create new chunk and add to dm
                print("Adding new opponent bid chunk")
                let chunk = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: opponentDice, myDice: ownDice, opponentBid: opponentBid, result: 1)//0: Bullshit & 1: Accept
                dm.addToDM(chunk)
            }
        }
        return response!
    }
    
    func makeCounterBid(myDice: Array<Int>, opponentBid: Array<Int>) -> Array<Int>{
        var response = [0,0]
        var choice = arc4random_uniform(4)
        var valid = false
        
        while !valid{
            
            switch choice {
            case 0:
                print("d+1")
                response = [opponentBid[0]+1, opponentBid[1]]
            case 1:
                print("p+1")
                response = [opponentBid[0], opponentBid[1]+1]
            case 2:
                print("d+1,p+1")
                response = [opponentBid[0]+1, opponentBid[1]+1]
            case 3:
                print("d+1,p-1")
                response = [opponentBid[0]+1, opponentBid[1]-1]
            default:
                print("Default: d+1")
                response = [opponentBid[0]+1, opponentBid[1]]
            }
            
            if(response[0]<11 && response[0]>0 && response[1]<7 && response[1]>0){
                valid = true
            } else {
                
                choice = arc4random_uniform(4)
                print("Try again")
            }
        }
        
        return response
    }
    
    func addToTrace(string s: String) {
        let timeString = String(format:"%.2f", time)
        trace += "\(timeString)  " + s + "\n"
    }
    
    func clearTrace() {
        trace = ""
    }
    
    /**
     When you want to use partial matching, override this function when you subclass Model
     */
    func mismatchFunction(x: Value, y: Value) -> Double? {
        if x == y {
            return 0
        } else {
            return -1
        }
    }
    
    /**
     Reset the model to its initial state
     */
    func reset() {
        time = 0
        if !(rememberMemory){
            dm.chunks = [:]
        }
        clearTrace()
        running = false
        waitingForAction = false
    }
    
    
    /**
     Generate a chunk with a unique ID starting with the given string
     - parameter s1: The base name of the chunk
     - returns: the new chunk
     */
    /*func generateNewChunk(string s1: String = "chunk") -> Chunk {
     let name = s1 + "\(chunkIdCounter)"
     chunkIdCounter += 1
     let chunk = Chunk(s: name, m: self)
     return chunk
     }*/
    
    func generateNewChunkOpponentDiceNum(s1: String, opponentDiceNum: Int) -> Chunk {
        let chunk = generateNewChunk(s1: s1, id: chunkIdCounterOpponentDiceNum)
        chunkIdCounterOpponentDiceNum += 1
        chunk.slotvals["type"] = Value.Text("opponentDiceNum")
        chunk.slotvals["opponentDiceNum"] = Value.NumberI(opponentDiceNum)
        chunk.printOrder = ["type", "opponentDiceNum"]
        return chunk
    }
    
    func generateNewChunkOpeningBid(s1: String, opponentDiceNum: Int, myDice: [Int], myBid: [Int]) -> Chunk {
        let chunk = generateNewChunk(s1: s1, id: chunkIdCounterOpeningBid)
        chunkIdCounterOpeningBid += 1
        chunk.slotvals["type"] = Value.Text("openingBid")
        chunk.slotvals["opponentDiceNum"] = Value.NumberI(opponentDiceNum)
        chunk.slotvals["myDice"] = Value.Array(myDice)
        chunk.slotvals["myBid"] = Value.Array(myBid)
        chunk.printOrder = ["type", "opponentDiceNum", "myDice", "myBid"]
        return chunk
    }
    
    func generateNewChunkOpponentBid(s1: String, opponentDiceNum: Int, myDice: [Int], opponentBid: [Int], result: Int) -> Chunk {
        let chunk = generateNewChunk(s1: s1, id: chunkIdCounterOpponentBid)
        chunkIdCounterOpponentBid += 1
        chunk.slotvals["type"] = Value.Text("opponentBid")
        chunk.slotvals["opponentDiceNum"] = Value.NumberI(opponentDiceNum)
        chunk.slotvals["myDice"] = Value.Array(myDice)
        chunk.slotvals["opponentBid"] = Value.Array(opponentBid)
        chunk.slotvals["result"] = Value.NumberI(result)
        chunk.printOrder = ["type", "opponentDiceNum", "myDice", "opponentBid", "result"]
        return chunk
    }
    
    func generateNewChunk(s1: String, id: Int) -> Chunk {
        let name = s1 + "\(id)"
        let chunk = Chunk(s: name, m: self)
        return chunk
    }
    
    func stringToValue(_ s: String) -> Value {
        let possibleNumVal = NumberFormatter().number(from: s)?.doubleValue
        if possibleNumVal != nil {
            return Value.NumberD(possibleNumVal!)
        }
        if let chunk = self.dm.chunks[s] {
            return Value.symbol(chunk)
        } else if s == "nil" {
            return Value.Empty
        } else {
            return Value.Text(s)
        }
    }
    
    func createInitialMemories(){
        //openingbids
        let chunkA1 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 5, myDice: [2,6], myBid: [3,6])
        dm.addToDM(chunkA1)
        
        let chunkA2 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 5, myDice: [2,5], myBid: [3,5])
        dm.addToDM(chunkA2)
        
        let chunkA3 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 5, myDice: [3,4], myBid: [3,4])
        dm.addToDM(chunkA3)
        
        let chunkA4 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 4, myDice: [2,3], myBid: [2,3])
        dm.addToDM(chunkA4)
        
        let chunkA5 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 4, myDice: [2,4], myBid: [2,5])
        dm.addToDM(chunkA5)
        
        let chunkA6 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 4, myDice: [1,1], myBid: [2,1])
        dm.addToDM(chunkA6)
        
        let chunkA7 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 3, myDice: [2,2], myBid: [2,2])
        dm.addToDM(chunkA7)
        
        let chunkA8 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 3, myDice: [1,3], myBid: [2,3])
        dm.addToDM(chunkA8)
        
        let chunkA9 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 3, myDice: [1,4], myBid: [1,4])
        dm.addToDM(chunkA9)
        
        let chunkA10 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 2, myDice: [1,5], myBid: [1,5])
        dm.addToDM(chunkA10)
        
        let chunkA11 = generateNewChunkOpeningBid(s1: "chunkOpeningBid", opponentDiceNum: 2, myDice: [1,6], myBid: [1,6])
        dm.addToDM(chunkA11)
        
        
        /*bidresponses
        let chunkB1 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB1)
    
        let chunkB2 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB2)
        
        let chunkB3 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB3)
        
        let chunkB4 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB4)
        
        let chunkB5 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB5)
        
        let chunkB6 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB6)
        
        let chunkB7 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB7)
        
        let chunkB8 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB8)
        
        let chunkB9 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB9)
        
        let chunkB10 = generateNewChunkOpponentBid(s1: "chunkOpponentBid", opponentDiceNum: 3, myDice: [0,0,2,1,1,0], opponentBid: [2,3], result: 0)//0: Bullshit & 1: Accept
        dm.addToDM(chunkB10)
        */
    }
}
