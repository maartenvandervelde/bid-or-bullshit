//
//  GameViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit


enum GameState: String {
    case GameStart
    case ModelOpeningBid
    case PlayerOpeningBid
    case ModelResponse
    case PlayerResponse
    case ModelCallsBullshit
    case PlayerCallsBullshit
    case ModelWinsRound
    case PlayerWinsRound
    case ModelWinsGame
    case PlayerWinsGame
}


class GameViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var gameInformation: UILabel!
    
    @IBOutlet weak var gameInfoPaddingLabel: UILabel!
    @IBOutlet weak var playerBidNumberOfDiceLabel: UILabel!
    @IBOutlet weak var playerBidNumberOfPipsView: UIImageView!
    @IBOutlet weak var playerBidNumberOfDiceStepper: UIStepper!
    @IBOutlet weak var playerBidNumberOfPipsStepper: UIStepper!
    @IBOutlet weak var playerInputButtons: UIStackView!
    @IBOutlet weak var playerBidButtons: UIStackView!
    @IBOutlet weak var playerBidConfirmButton: UIButton!
    @IBOutlet weak var playerBullshitButton: UIButton!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var quit: UIButton!
    
//    let diceImages = [1: UIImage(named: "die-1"),
//                      2: UIImage(named: "die-2"),
//                      3: UIImage(named: "die-3"),
//                      4: UIImage(named: "die-4"),
//                      5: UIImage(named: "die-5"),
//                      6: UIImage(named: "die-6")]

    let diceImages = [1: UIImage(named: "dop1"),
                      2: UIImage(named: "dop2"),
                      3: UIImage(named: "dop3"),
                      4: UIImage(named: "dop4"),
                      5: UIImage(named: "dop5"),
                      6: UIImage(named: "dop6")]

    let cupImages = [
        "Captain Hook": UIImage(named: "hookscup"),
        "Davy Jones": UIImage(named: "davyjonescup"),
        "Ching Shih": UIImage(named: "shihscup")
    ]
    
    var opponent: OpponentCharacter? = nil
    
    let perudo = Perudo()
    
    var humanPlayer: HumanPlayer?
    var modelPlayer: ModelPlayer?
    
    private var gamestate = GameState.GameStart {
        didSet {
            
            // The visibility of interface elements is controlled here.
            // Whenenver the gamestate changes, hide all state-dependent interface elements, and unhide those that are relevant in the current state.
            
            playerBidButtons.isHidden = true
            playerBullshitButton.isHidden = true
            rollButton.isHidden = true
            playAgainButton.isHidden = true
            
            switch gamestate {
            
            case .GameStart:
                print("Starting a new game")
                setStartingPlayer()
                let chunk = modelPlayer?.generateNewChunkOpponentDiceNum(s1: "chunkOppDiceNum", opponentDiceNum: (humanPlayer?.diceList.count)!)
                modelPlayer?.dm.addToDM(chunk!)
            
            case .ModelOpeningBid:
                print("\(opponent!.name) makes an opening bid")
                statusMessage = "It's \(opponent!.name)'s turn to start."
                modelBid = modelPlayer!.makeOpeningBid()
            
            case .PlayerOpeningBid:
                print("The player makes an opening bid")
                statusMessage = "It's your turn to start. Make an opening bid."
                playerBid = Bid()
                modelBid = Bid()
                playerBidButtons.isHidden = false
                playerBidConfirmButton.isEnabled = true
            
            case .ModelResponse:
                print("\(opponent!.name) responds to the player's bid")
                statusMessage = "You bid \(playerBid.repr()). \(opponent!.name) will now respond."
                
                let modelResponse = modelPlayer!.respondToBid(bid: playerBid)
                processModelResponse(modelResponse: modelResponse)
            
            case .PlayerResponse:
                print("The player responds to \(opponent!.name)'s bid")
                statusMessage = "\(opponent!.name) bid \(modelBid.repr()). It is your turn."
                playerBid = modelBid
                
                playerBidButtons.isHidden = false
                playerBullshitButton.isHidden = false
            
            case .ModelCallsBullshit:
                print("\(opponent!.name) calls bullshit")
                statusMessage = "\(opponent!.name) does not believe your bid of \(playerBid.repr()). Let's see who's right."
                
                let bidCorrect = Perudo.isBidCorrect(bid: playerBid, player1dice: humanPlayer!.diceList, player2dice: modelPlayer!.diceList)
                
                if bidCorrect {
                    // delay for 3 seconds
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.drawOpponentDice(hidden: false)
                        self.gamestate = .PlayerWinsRound
                    }
                } else {
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.drawOpponentDice(hidden: false)
                        self.gamestate = .ModelWinsRound
                    }
                }

            case .PlayerCallsBullshit:
                print("The player calls bullshit")
                statusMessage = "You don't believe \(opponent!.name)'s bid of \(modelBid.repr()). Let's see who's right."
                
                let bidCorrect = Perudo.isBidCorrect(bid: modelBid, player1dice: humanPlayer!.diceList, player2dice: modelPlayer!.diceList)
                
                if bidCorrect {
                    // delay for 3 seconds
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.drawOpponentDice(hidden: false)
                        self.gamestate = .ModelWinsRound
                    }
                } else {
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.drawOpponentDice(hidden: false)
                        self.gamestate = .PlayerWinsRound
                    }
                }
            
            case .ModelWinsRound:
                print("\(opponent!.name) wins this round")
                statusMessage = "\(opponent!.name) wins this round. Final bid: \(modelBid.repr())."
                humanPlayer?.discardDice()
                
                let chunk = modelPlayer?.generateNewChunkOpponentDiceNum(s1: "chunkOppDiceNum", opponentDiceNum: (humanPlayer?.diceList.count)!)
                modelPlayer?.dm.addToDM(chunk!)
                
                let gameover = checkIfGameOver()
                if !gameover {
                 rollButton.isHidden = false
                }
                
                
            case .PlayerWinsRound:
                print("You win this round")
                statusMessage = "You win this round. Final bid: \(modelBid.repr())."
                modelPlayer!.discardDice()
                
                let gameover = checkIfGameOver()
                if !gameover {
                    rollButton.isHidden = false
                }
                
            case .ModelWinsGame:
                print("\(opponent!.name) has won the game")
                statusMessage = statusMessage! + " \(opponent!.name) has won the game."
                
                playAgainButton.isHidden = false
                
            case .PlayerWinsGame:
                print("The player has won the game")
                statusMessage = statusMessage! + " You have won the game."
                
                playAgainButton.isHidden = false
            
            }
            
            let when = DispatchTime.now() + 0.05
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.drawOpponentSpeechBubble(message: self.modelPlayer!.speak(gamestate: self.gamestate))
            }

        }
    }
    
    private var statusMessage: String? {
        didSet {
            gameInformation.text = statusMessage!
        }
    }
    
    private var playerBid = Bid() {
        didSet {
            playerBidNumberOfDiceStepper.value = Double(playerBid.numberOfDice)
            playerBidNumberOfPipsStepper.value = Double(playerBid.numberOfPips)
            playerBidNumberOfDiceLabel.text = "\(playerBid.numberOfDice)"
            playerBidNumberOfPipsView.image = diceImages[playerBid.numberOfPips]!
            playerBid.printBid()
            if gamestate != .PlayerOpeningBid {
                if (Perudo.isBidLegal(previous: modelBid, new: playerBid)) {
                    print("This bid is legal.")
                    playerBidConfirmButton.isEnabled = true
                
                } else {
                    print("This bid is NOT legal!")
                    playerBidConfirmButton.isEnabled = false
                }
            }
        }
    }
    
    private var modelBid = Bid() {
        didSet {
            // delay for 3 seconds
            if gamestate != .PlayerOpeningBid {
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.gamestate = .PlayerResponse
                }
            }
        }
    }

    
    @IBAction func setPlayerBidNumberOfDice(_ sender: UIStepper) {
        playerBid.numberOfDice = Int(sender.value)
    }
    @IBAction func setPlayerBidNumberOfPips(_ sender: UIStepper) {
        playerBid.numberOfPips = Int(sender.value)
    }
    
    
    
    /// BACK BUTTON
    // Return to main menu, throwing away the current game if in progress (after user confirmation).
    @IBAction func backToMenu(_ sender: UIButton) {
        if !(gamestate == .PlayerWinsGame || gamestate == .ModelWinsGame) {
            let alert = UIAlertController(title: "Return to menu?", message: "Are you sure you want to return to the menu? Your progress in the game will be lost.", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                self.performSegue(withIdentifier: "unwindToMenuFromGame", sender: self)
            }
            let noAction = UIAlertAction(title: "No", style: .cancel)
            
            alert.addAction(noAction)
            alert.addAction(yesAction)
            
            present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "unwindToMenuFromGame", sender: self)
        }
    }
    
    /// ROLL BUTTON
    @IBAction func roll(_ sender: UIButton) {
        humanPlayer!.rollDice()
        drawPlayerDice()
        modelPlayer!.rollDice()
        drawOpponentDice(hidden: true)
        gamestate = .GameStart
    }
    
    /// PLAY AGAIN BUTTON
    @IBAction func playAgain(_ sender: UIButton) {
        reset()
    }

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if opponent != nil {
            opponentImage.image = opponent!.image
        }
        
        humanPlayer = HumanPlayer()
        modelPlayer = ModelPlayer(character: opponent!)
        
        
        drawPlayerDice()
        drawOpponentDice(hidden: true)
        
        gamestate = .PlayerOpeningBid
        //gameInformation.layer.borderWidth = 1
        //gameInformation.backgroundColor = UIColor.white
        //gameInformation.textColor = UIColor.black
        //gameInformation.layer.cornerRadius = 10
        //gameInformation.layer.shadowOpacity = 0.8
        //gameInformation.layer.shadowRadius = 5
        //gameInformation.layer.shadowOffset = CGSize(width: 2, height: 2)

        setBackgroundImage()

        gameInfoPaddingLabel.layer.cornerRadius = 10
        gameInfoPaddingLabel.layer.shadowOpacity = 0.8
        gameInfoPaddingLabel.layer.shadowRadius = 5
        gameInfoPaddingLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        playerBidNumberOfPipsView.layer.cornerRadius = 5 // round the corners of the dice
        playerBidNumberOfPipsView.layer.masksToBounds = true
        
        opponentImage.layer.cornerRadius = 5
        opponentImage.layer.masksToBounds = true
        
        
        // Adjust appearance of buttons
        rollButton.layer.cornerRadius = 10
        rollButton.contentEdgeInsets = UIEdgeInsets(top:8, left:25,bottom:8,right:25)
        
        playerBullshitButton.layer.cornerRadius = 10
        playerBullshitButton.contentEdgeInsets = UIEdgeInsets(top:8, left:20,bottom:8,right:20)
        
        playerBidConfirmButton.layer.cornerRadius = 10
        playerBidConfirmButton.contentEdgeInsets = UIEdgeInsets(top:8, left:50,bottom:8,right:50)
        
        playAgainButton.layer.cornerRadius = 10
        playAgainButton.contentEdgeInsets = UIEdgeInsets(top:8, left:50,bottom:8,right:50)

        
        quit.layer.cornerRadius = 10
        quit.contentEdgeInsets = UIEdgeInsets(top:8, left:15,bottom:8,right:15)

    }

    private func setStartingPlayer() {
        // Choose the starting player with a coin flip
        gamestate = (Int(arc4random_uniform(2)) == 1) ?  .PlayerOpeningBid : .ModelOpeningBid
    }
    
    private func checkIfGameOver() -> Bool {
        if (humanPlayer!.playerHasLost) {
            gamestate = .ModelWinsGame
            return true
        } else if (modelPlayer!.playerHasLost) {
            gamestate = .PlayerWinsGame
            return true
        }
        return false
    }

    private func reset() {
        print("Resetting the game.")
        humanPlayer = HumanPlayer()
        modelPlayer = ModelPlayer(character: opponent!)
        gamestate = .GameStart
        drawPlayerDice()
        drawOpponentDice(hidden: true)
    }
    
    
    /// GAMEPLAY FUNCTIONS
    
    @IBAction func processPlayerBid(_ sender: UIButton) {
        gamestate = .ModelResponse
    }

    @IBAction func playerSaysBullshit(_ sender: UIButton) {
        gamestate = .PlayerCallsBullshit
    }
    
    
    // Responding to a shake gesture
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake {
            if !rollButton.isHidden {
                roll(_: UIButton())
            }
        }
    }
    
    
    private func processModelResponse(modelResponse: Bid?) {
        if modelResponse != nil {
            modelBid = modelResponse!
        } else {
            // delay for 3 seconds
            if gamestate != .PlayerOpeningBid {
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.gamestate = .ModelCallsBullshit
                }
            }
        }
    }
    
    
    /// DRAWING FUNCTIONS
    
    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "nauticalmap")
        backgroundImageView.alpha = 0.25
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }
    
    
    private func drawPlayerDice() {
        
        // Remove previous images of dice from the view
        for subView in view.subviews {
            if let dieView = subView as? DieUIImageView {
                if dieView.owner == "player" {
                    dieView.removeFromSuperview()
                }
            }
        }
        
        
        // Retrieve the player's current dice
        let playerDice = humanPlayer!.diceList
        
        // Draw each die in the view
        for (index, die) in playerDice.enumerated() {
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.owner = "player"
            dieImageView.frame = CGRect(x: 200 + (76 * index), y: 900, width: 64, height: 64)
            dieImageView.layer.cornerRadius = 5 // round the corners of the dice
            dieImageView.layer.masksToBounds = true
            view.addSubview(dieImageView)
        }
    }
    
    private func drawOpponentDice(hidden: Bool) {
        
        // Remove any previous images of dice and cups from the view
        for subView in view.subviews {
            if let dieView = subView as? DieUIImageView {
                if dieView.owner == "opponent" {
                    dieView.removeFromSuperview()
                }
            } else if let cupView = subView as? CupUIImageView {
                cupView.removeFromSuperview()
            }
        }
        
        // Retrieve the opponent's current dice
        let opponentDice = modelPlayer!.diceList
        
        

        
        // Draw each die in the view
        for (index, die) in opponentDice.enumerated() {
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.owner = "opponent"
            //dieImageView.frame = CGRect(x: 450 + (60 * index), y: 185, width: 48, height: 48)
            dieImageView.frame = CGRect(x: 500 + (42 * index), y: 220, width: 36, height: 36)
            dieImageView.layer.cornerRadius = 5 // round the corners of the dice
            dieImageView.layer.masksToBounds = true
            view.addSubview(dieImageView)
        }
        
        
        // If the dice are hidden, draw the cup over them
        if hidden {
            if let cupImage = cupImages[opponent!.name] {
                let cupImageView = CupUIImageView(image: cupImage)
                cupImageView.frame = CGRect(x: 475, y: 75, width: 250, height: 220)
                view.addSubview(cupImageView)
            }
        }
        
    }
    
    
    private func drawOpponentSpeechBubble(message: String) {
        // Is there a previous speech bubble on screen? Then remove it first.
        removeExistingSpeechBubble()
        
        // Show a new speech bubble with the specified message
        let bubbleView = SpeechBubbleView(baseView: opponentImage, text: message, fontSize: 20.0)
        view.addSubview(bubbleView)
        
        // Make sure that the speech bubble is in front of everything else
        view.bringSubview(toFront: bubbleView)
    }
    
    private func removeExistingSpeechBubble() {
        for subview in view.subviews {
            if let subview = subview as? SpeechBubbleView {
                subview.removeFromSuperview()
            }
        }
    }
}
