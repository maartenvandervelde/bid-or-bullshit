//
//  GameViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

/**
 The state of the game at any point in time is one of the following.
*/
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
    
    // Interface elements
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
    
    var modelWonLastRound: Bool?
    var latestBid: Bid?
    
    /**
     The game state keeps track of the current position in the game.
     Changes in the game state prompt changes in the interface (which elements are shown to the user).
     Changes in the game state will also prompt communication with the model, e.g. to ask it for a new bid.
    */
    private var gamestate = GameState.GameStart {
        didSet {
            
            // The visibility of interface elements is controlled here.
            // Whenenver the gamestate changes, hide all state-dependent interface elements, and unhide those that are relevant in the current state.
            playerBidButtons.isHidden = true
            playerBullshitButton.isHidden = true
            rollButton.isHidden = true
            playAgainButton.isHidden = true
            
            switch gamestate {
            
            case .GameStart: // Start of a new game (round)
                print("Starting a new game")
                
                // At the start of each round, the model knows with certainty how many dice the human player has
                modelPlayer?.encodeHumanPlayerDiceNum(count: humanPlayer!.diceList.count)
                
                // Select the player that starts the bidding
                setStartingPlayer()
            
            case .ModelOpeningBid: // The model makes an opening bid
                print("\(opponent!.name) makes an opening bid")
                
                statusMessage = "It's \(opponent!.name)'s turn to start."
                modelBid = modelPlayer!.makeOpeningBid()
                latestBid = modelBid
            
            case .PlayerOpeningBid: // The player makes an opening bid
                print("The player makes an opening bid")
                
                statusMessage = "It's your turn to start. Make an opening bid."
                
                // Add extra instructions in EASY mode
                if (opponent!.difficulty == "easy") {
                    statusMessage = statusMessage! + " An opening bid can be any number of dice with any number of pips. Hint: look at your dice!"
                }
                
                playerBid = Bid()
                modelBid = Bid()
                playerBidButtons.isHidden = false
                playerBidConfirmButton.isEnabled = true
            
            case .ModelResponse: // The model responds to the player's bid
                print("\(opponent!.name) responds to the player's bid")
                
                statusMessage = "You bid \(playerBid.repr()). \(opponent!.name) will now respond."
                
                let modelResponse = modelPlayer!.respondToBid(bid: playerBid)
                processModelResponse(modelResponse: modelResponse)
            
            case .PlayerResponse: // The player responds to the model's bid
                print("The player responds to \(opponent!.name)'s bid")
                
                statusMessage = "\(opponent!.name) bid \(modelBid.repr()). It is your turn."
                
                // Add extra instructions in EASY mode
                if (opponent!.difficulty == "easy") {
                    statusMessage = statusMessage! + " If you want to bid, up the dice and / or pips by 1, or up the dice and lower the pips."
                }
                
                
                playerBid = latestBid!
                
                playerBidButtons.isHidden = false
                playerBullshitButton.isHidden = false
            
            case .ModelCallsBullshit: // The model doesn't believe the player's bid
                print("\(opponent!.name) calls bullshit")
                
                statusMessage = "\(opponent!.name) does not believe your bid of \(playerBid.repr()). Let's see who's right."
                
                // Evaluate the bid made by the player
                let bidCorrect = Perudo.isBidCorrect(bid: playerBid, player1dice: humanPlayer!.diceList, player2dice: modelPlayer!.diceList)
                
                // If the player's bid was correct, declare player the winner of the round. If not, the model is the winner.
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

            case .PlayerCallsBullshit: // The player does not believe the model's bid
                print("The player calls bullshit")
                
                statusMessage = "You don't believe \(opponent!.name)'s bid of \(modelBid.repr()). Let's see who's right."
                
                // Evaluate the model's bid
                let bidCorrect = Perudo.isBidCorrect(bid: modelBid, player1dice: humanPlayer!.diceList, player2dice: modelPlayer!.diceList)
                
                // If the model's bid was correct, declare the model the winner
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
            
            case .ModelWinsRound: // The model wins the round
                modelWonLastRound = true
                print("\(opponent!.name) wins this round")
                
                statusMessage = "\(opponent!.name) wins this round. Final bid: \(latestBid!.repr())."
                
                discardDice(player: "human")
                
                let gameover = checkIfGameOver()
                if !gameover {
                    let when = DispatchTime.now() + 1.5
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.rollButton.isHidden = false
                    }
                }
                
            case .PlayerWinsRound: // The player wins the round
                modelWonLastRound = false
                print("You win this round")
                
                statusMessage = "You win this round. Final bid: \(latestBid!.repr())."
                discardDice(player: "model")
                
                let gameover = checkIfGameOver()
                if !gameover {
                    let when = DispatchTime.now() + 1.5
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.rollButton.isHidden = false
                    }
                }
                
            case .ModelWinsGame: // The player has no more dice. The model wins
                print("\(opponent!.name) has won the game")
                
                statusMessage = statusMessage! + " \(opponent!.name) has won the game."
                
                playAgainButton.isHidden = false
                
                modelPlayer?.printChunksInDM()
                
            case .PlayerWinsGame: // The model has no more dice. The player wins
                print("The player has won the game")
                
                statusMessage = statusMessage! + " You have won the game."
                
                playAgainButton.isHidden = false
                
                modelPlayer?.printChunksInDM()

            }
            
            // Draw model player's speech bubble
            let when = DispatchTime.now() + 0.05
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.drawOpponentSpeechBubble(message: self.modelPlayer!.speak(gamestate: self.gamestate))
            }
            
            // Tell model to update its time
            modelPlayer?.updateTime()

        }
    }
    
    /**
     Text label in the middle of the screen
    */
    private var statusMessage: String? {
        didSet {
            gameInformation.text = statusMessage!
        }
    }
    
    /**
     If the player's bid is updated, update the steppers and labels on screen accordingly.
    */
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
    
    /**
     If the model's bid is updated, let the player respond (after a delay).
    */
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

    // Functions that take stepper actions and translate them to the internal representation of the player's bid
    @IBAction func setPlayerBidNumberOfDice(_ sender: UIStepper) {
        playerBid.numberOfDice = Int(sender.value)
    }
    @IBAction func setPlayerBidNumberOfPips(_ sender: UIStepper) {
        playerBid.numberOfPips = Int(sender.value)
    }
    
    /// BACK BUTTON
    /**
     Return to main menu, throwing away the current game if one is in progress (after user confirmation).
    */
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
        drawPlayerDice(spin: true)
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
        
        // Set image of opponent in top-left of screen
        if opponent != nil {
            opponentImage.image = opponent!.image
        }
        
        // Initialise players
        humanPlayer = HumanPlayer()
        modelPlayer = ModelPlayer(character: opponent!)
        modelPlayer?.name = (opponent?.name)!
        
        // draw player's dice at the bottom of the screen with spinning animation
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.drawPlayerDice(spin: true)
        }
        // Draw opponent's dice, hidden by a cup
        drawOpponentDice(hidden: true)
        
        // The player always starts the first round
        gamestate = .GameStart

        setBackgroundImage()

        // Adjust appearance of the game information label in the center of the screen
        gameInfoPaddingLabel.layer.cornerRadius = 10
        gameInfoPaddingLabel.layer.shadowOpacity = 0.8
        gameInfoPaddingLabel.layer.shadowRadius = 5
        gameInfoPaddingLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        gameInfoPaddingLabel.backgroundColor = UIColor(patternImage: UIImage(named: "paper")!)
        gameInfoPaddingLabel.contentMode = .scaleAspectFill
        gameInfoPaddingLabel.alpha = 1
        
        // round the corners of the bid dice
        playerBidNumberOfPipsView.layer.cornerRadius = 5
        playerBidNumberOfPipsView.layer.masksToBounds = true
        
        // round the corners of the opponent image
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
    

    /**
     Sets a gamestate that makes one of the players the starting player.
    */
    private func setStartingPlayer() {
        // If it's the first round, the human player starts
        if modelWonLastRound == nil {
            //gamestate = (Int(arc4random_uniform(2)) == 1) ?  .PlayerOpeningBid : .ModelOpeningBid
            gamestate = .PlayerOpeningBid
        } else {
            // Otherwise the loser of the last round begins
            gamestate = modelWonLastRound! ? .PlayerOpeningBid : .ModelOpeningBid
        }
    }
    
    /**
     Checks if one of the players has lost all their dice, and if so, sets the gamestate accordingly.
    */
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

    /**
     Resets the game so that a new game can be started from scratch.
    */
    private func reset() {
        print("Resetting the game.")
        humanPlayer = HumanPlayer()
        modelPlayer = ModelPlayer(character: opponent!)
        gamestate = .GameStart
        drawPlayerDice(spin: true)
        drawOpponentDice(hidden: true)
    }
    
    
    /// GAMEPLAY FUNCTIONS
    
    @IBAction func processPlayerBid(_ sender: UIButton) {
        latestBid = playerBid
        gamestate = .ModelResponse
    }

    @IBAction func playerSaysBullshit(_ sender: UIButton) {
        gamestate = .PlayerCallsBullshit
    }
    
    
    /**
     Responds to a shake event: when the player shakes the device when the Roll button is on screen, treat it as a button press.
    */
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEventSubtype.motionShake {
            if !rollButton.isHidden {
                roll(_: UIButton())
            }
        }
    }
    
    /**
     Parses a response made by the model.
    */
    private func processModelResponse(modelResponse: Bid?) {
        if modelResponse != nil {
            modelBid = modelResponse!
            latestBid = modelResponse!
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
    
    var playerDiceViews: [DieUIImageView]?
    var rightMostPlayerDie: DieUIImageView?
    var rightMostModelDie: DieUIImageView?
    var cupImageView: CupUIImageView?
    
    /**
     Set the map image as the background of the view.
     */
    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "nauticalmap")
        backgroundImageView.alpha = 0.25
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }
    
    /**
     Draws the player's dice at the bottom of the screen.
     Parameters:
        spin: Bool      -       if True, dice are given a spin animation
     */
    private func drawPlayerDice(spin: Bool) {
        
        // Remove previous images of dice from the view
        for subView in view.subviews {
            if let dieView = subView as? DieUIImageView {
                if dieView.owner == "player" {
                    dieView.removeFromSuperview()
                }
            }
        }
        
        playerDiceViews = []
        
        
        // Retrieve the player's current dice
        let playerDice = humanPlayer!.diceList
        
        // Draw each die in the view
        for (index, die) in playerDice.enumerated() {
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.owner = "player"
            dieImageView.frame = CGRect(x: 180 + (84 * index), y: 900, width: 72, height: 72)
            dieImageView.layer.cornerRadius = 5 // round the corners of the dice
            dieImageView.layer.masksToBounds = true
            view.addSubview(dieImageView)
            
            playerDiceViews!.append(dieImageView)
            
            // Keep track of the rightmost dieImageView so that it can be thrown out later if the player loses
            if (index == playerDice.count - 1) {
                rightMostPlayerDie = dieImageView
            }
        }
        
        if spin {
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            for diceview in self.playerDiceViews! {
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                                diceview.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                            }
            },
                           completion: { finished in
            })
            
        }
    }
    
    /**
     Draws the opponent's dice at the top of the screen.
     Parameters:
     hidden: Bool      -       if True, dice are hidden behind the opponent's cup.
                               if False, cup is drawn but is removed via an animation.
     */
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
            let name = opponent!.name == "Captain Hook" ? "hook" : opponent!.name == "Davy Jones" ? "davy" : "ching"
            let image = UIImage(named: "\(name)dop\(die)")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.owner = "opponent"
            dieImageView.frame = CGRect(x: 365 + (54 * index), y: 285, width: 42, height: 42)
            dieImageView.layer.cornerRadius = 5 // round the corners of the dice
            dieImageView.layer.masksToBounds = true
            view.addSubview(dieImageView)
            
            // Keep track of the opponent's rightmost dieImageView for throwing away later if opponent loses
            if (index == opponentDice.count - 1) {
                rightMostModelDie = dieImageView
            }
        }
        
        
        if let cupImage = cupImages[opponent!.name] {
            cupImageView = CupUIImageView(image: cupImage)
            cupImageView!.frame = CGRect(x: 350, y: 100, width: 285, height: 280)
            view.addSubview(cupImageView!)
        }
        
        // If the dice are not hidden, animate the cup
        if !hidden {
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: {
                            self.cupImageView?.center = CGPoint(x: 492, y: -200)
            },
                           completion: { finished in
            })
        }
        
    }
    
    /**
     Throws away one die of one of the players.
     The die is removed from the player's dicelist and is also visually removed from screen via a rolling animation.
     Parameters:
        player: String      -       The name of the player whose die should be discarded ("human" or "model").
    */
    private func discardDice(player: String) {
        
        switch(player) {
        case "model":
            modelPlayer!.discardDice()
            
            UIView.animate(withDuration: 1.0,
                           delay: 1.0,
                           options: .curveEaseIn,
                           animations: {
                            self.rightMostModelDie?.center = CGPoint(x: 1000, y: 306)
                            self.rightMostModelDie?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                            self.rightMostModelDie?.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                            self.rightMostModelDie?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                            self.rightMostModelDie?.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            },
                           completion: { finished in
            })
            
        case "human":
            humanPlayer!.discardDice()
            
            UIView.animate(withDuration: 1.0,
                           delay: 0.5,
                           options: .curveEaseIn,
                           animations: {
                            self.rightMostPlayerDie?.center = CGPoint(x: 1000, y: 936)
                            self.rightMostPlayerDie?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                            self.rightMostPlayerDie?.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                            self.rightMostPlayerDie?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                            self.rightMostPlayerDie?.transform = CGAffineTransform(rotationAngle: CGFloat(0))

            },
                           completion: { finished in
})
        default:
            break
        }
    }
    
    /**
     Draws speech bubble to the right of the opponent's image.
     Parameters:
        message: String     -       The text that goes inside the speech bubble (beware of its length!).
    */
    private func drawOpponentSpeechBubble(message: String) {
        // Is there a previous speech bubble on screen? Then remove it first.
        removeExistingSpeechBubble()
        
        // Show a new speech bubble with the specified message
        let bubbleView = SpeechBubbleView(baseView: opponentImage, text: message, fontSize: 20.0)
        view.addSubview(bubbleView)
        
        // Make sure that the speech bubble is in front of everything else
        view.bringSubview(toFront: bubbleView)
    }
    
    /**
     Removes any speech bubbles that may be on screen.
    */
    private func removeExistingSpeechBubble() {
        for subview in view.subviews {
            if let subview = subview as? SpeechBubbleView {
                subview.removeFromSuperview()
            }
        }
    }
}
