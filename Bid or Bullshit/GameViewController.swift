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
    
    @IBOutlet weak var playerBidNumberOfDiceLabel: UILabel!
    @IBOutlet weak var playerBidNumberOfPipsView: UIImageView!
    @IBOutlet weak var playerBidNumberOfDiceStepper: UIStepper!
    @IBOutlet weak var playerBidNumberOfPipsStepper: UIStepper!
    @IBOutlet weak var playerInputButtons: UIStackView!
    @IBOutlet weak var playerBidButtons: UIStackView!
    @IBOutlet weak var playerBullshitButton: UIButton!
    @IBOutlet weak var rollButton: UIButton!
    
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

    
    var opponent: OpponentCharacter? = nil
    
    let perudo = Perudo()
    
    let humanPlayer = HumanPlayer()
    let modelPlayer = ModelPlayer()
    
    private var gamestate = GameState.GameStart {
        didSet {
            switch gamestate {
            
            case .GameStart:
                print("Starting a new game")
            
            case .ModelOpeningBid:
                print("The model makes an opening bid")
                modelPlayer.makeOpeningBid()
            
            case .PlayerOpeningBid:
                print("The player makes an opening bid")
                statusMessage = "It's your turn to start. Make an opening bid."
                playerBidButtons.isHidden = false
                playerBullshitButton.isHidden = true
            
            case .ModelResponse:
                print("The model responds to the player's bid")
                statusMessage = "You bid \(playerBid.repr()). The model will now respond."
                playerBidButtons.isHidden = true
                playerBullshitButton.isHidden = true
                let modelResponse = modelPlayer.respondToBid(bid: playerBid)
                if modelResponse != nil {
                    modelBid = modelResponse!
                }
            
            case .PlayerResponse:
                print("The player responds to the model's bid")
                statusMessage = "The model bid \(modelBid.repr()). It is your turn."
                playerBid = modelBid
                playerBidButtons.isHidden = false
                playerBullshitButton.isHidden = false
            
            case .ModelCallsBullshit:
                print("The model calls bullshit")
                statusMessage = "The model does not believe your bid of \(playerBid.repr()). Let's see who's right."
                playerBidButtons.isHidden = true
                playerBullshitButton.isHidden = true

            case .PlayerCallsBullshit:
                print("The player calls bullshit")
                statusMessage = "You don't believe the model's bid of \(modelBid.repr()). Let's see who's right."
                playerBidButtons.isHidden = true
                playerBullshitButton.isHidden = true
                
                let bidCorrect = Perudo.isBidCorrect(bid: modelBid, player1dice: humanPlayer.diceList, player2dice: modelPlayer.diceList)
                
                if bidCorrect {
                    // delay for 3 seconds
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.gamestate = .ModelWinsRound
                    }
                } else {
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.gamestate = .PlayerWinsRound
                    }
                }
            
            case .ModelWinsRound:
                print("The model wins this round")
                statusMessage = "The model wins this round. Final bid: \(modelBid.repr()). The model's dice: \(modelPlayer.diceList)."
                humanPlayer.discardDice()
                
                rollButton.isHidden = false
                
                
            case .PlayerWinsRound:
                print("You win this round")
                statusMessage = "You win this round. Final bid: \(modelBid.repr()). The model's dice: \(modelPlayer.diceList)."
                
                rollButton.isHidden = false
                
                
            case .ModelWinsGame:
                print("The model has won the game")
                statusMessage = "The model has won the game."
                
            case .PlayerWinsGame:
                print("The player has won the game")
                statusMessage = "You have won the game."
            
            }
            
            drawOpponentSpeechBubble(message: modelPlayer.speak(gamestate: gamestate))
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
        }
    }
    
    private var modelBid = Bid() {
        didSet {
            // delay for 3 seconds
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.gamestate = .PlayerResponse
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
    // Return to main menu, throwing away the current game (after user confirmation).
    @IBAction func backToMenu(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Return to menu?", message: "Are you sure you want to return to the menu? Your progress in the game will be lost.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "unwindToMenuFromGame", sender: self)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true)
    }
    
    /// ROLL BUTTON
    @IBAction func roll(_ sender: UIButton) {
        humanPlayer.rollDice()
        drawPlayerDice()
        gamestate = .PlayerOpeningBid
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if opponent != nil {
            opponentImage.image = opponent!.image
        }
        
        setBackgroundImage()
        
        drawPlayerDice()
        
        gamestate = .PlayerOpeningBid
        gameInformation.layer.borderWidth = 1
        gameInformation.backgroundColor = UIColor.white
        gameInformation.textColor = UIColor.black
    }

    
    /// GAMEPLAY FUNCTIONS
    
    @IBAction func processPlayerBid(_ sender: UIButton) {
        gamestate = .ModelResponse
    }

    @IBAction func playerSaysBullshit(_ sender: UIButton) {
        gamestate = .PlayerCallsBullshit
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
        for dieView in view.subviews {
            if let dieView = dieView as? DieUIImageView {
                dieView.removeFromSuperview()
            }
        }
        
        // Retrieve the player's current dice
        let playerDice = humanPlayer.diceList
        
        // Draw each die in the view
        for (index, die) in playerDice.enumerated() {
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.frame = CGRect(x: 200 + (76 * index), y: 900, width: 64, height: 64)
            view.addSubview(dieImageView)
        }
    }
    
    private func drawOpponentSpeechBubble(message: String) {
        // Is there a previous speech bubble on screen? Then remove it first.
        removeExistingSpeechBubble()
        
        // Show a new speech bubble with the specified message
        let bubbleView = SpeechBubbleView(baseView: opponentImage, text: message, fontSize: 20.0)
        view.addSubview(bubbleView)
    }
    
    private func removeExistingSpeechBubble() {
        for subview in view.subviews {
            if let subview = subview as? SpeechBubbleView {
                subview.removeFromSuperview()
            }
        }
    }
}
