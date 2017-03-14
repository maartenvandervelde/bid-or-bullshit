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
    case Results
    case GameOver
}


class GameViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var gameInformation: UILabel!
    
    @IBOutlet weak var playerBidNumberOfDiceLabel: UILabel!
    @IBOutlet weak var playerBidNumberOfPipsView: UIImageView!
    @IBOutlet weak var playerBidNumberOfDiceStepper: UIStepper!
    @IBOutlet weak var playerBidNumberOfPipsStepper: UIStepper!
    @IBOutlet weak var playerInputButtons: UIStackView!
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
                playerInputButtons.isHidden = false
            
            case .ModelResponse:
                print("The model responds to the player's bid")
                playerInputButtons.isHidden = true
                modelPlayer.respondToBid(bid: Bid(numberOfDice: 3, numberOfPips: 2))
            
            case .PlayerResponse:
                print("The player responds to the model's bid")
            
            case .Results:
                print("Determining the winner")
            
            case .GameOver:
                print("Game over")
            
            }
            drawOpponentSpeechBubble(message: modelPlayer.speak(gamestate: gamestate))
        }
    }
    
    private var playerBid = Bid() {
        didSet {
            playerBidNumberOfDiceLabel.text = "\(playerBid.numberOfDice)"
            playerBidNumberOfPipsView.image = diceImages[playerBid.numberOfPips]!
            playerBid.printBid()
        }
    }
    
    private var modelBid = Bid() {
        didSet {
            
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
        gameInformation.backgroundColor = UIColor.lightGray
        
    }

    
    /// GAMEPLAY FUNCTIONS
    

    
    
    
    
    
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
