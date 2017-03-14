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
    
    private var gamestate = GameState.GameStart
    
    private var playerBidNumberOfDice: Int? {
        didSet {
            playerBidNumberOfDiceLabel.text = "\(playerBidNumberOfDice!)"
        }
    }
    private var playerBidNumberOfPips: Int? {
        didSet {
            playerBidNumberOfPipsView.image = diceImages[playerBidNumberOfPips!]!
        }
    }
    private var modelBidNumberOfDice: Int?
    private var modelBidNumberOfPips: Int?
    
    @IBAction func setPlayerBidNumberOfDice(_ sender: UIStepper) {
        playerBidNumberOfDice = Int(sender.value)
    }
    @IBAction func setPlayerBidNumberOfPips(_ sender: UIStepper) {
        playerBidNumberOfPips = Int(sender.value)
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
        //drawOpponentSpeechBubble(message: "Do you fear death?")
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if opponent != nil {
            opponentImage.image = opponent!.image
        }
        
        setBackgroundImage()
        
        drawPlayerDice()
        
        
        gamestate = GameState.GameStart
        
        gameInformation.layer.borderWidth = 1
        gameInformation.backgroundColor = UIColor.lightGray
        
    }

    
    /// GAMEPLAY FUNCTIONS
    
    private func drawOpponentSpeechBubble(message: String) {
        let popover = storyboard?.instantiateViewController(withIdentifier: "speechbubble")
        popover?.modalPresentationStyle = .popover
        popover?.popoverPresentationController?.delegate = self
        popover?.popoverPresentationController?.sourceView = self.view
        popover?.popoverPresentationController?.sourceRect = CGRect(x: 50, y: 100, width: 400, height: 50)
        popover?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
        self.present(popover!, animated: true)
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
            print(die)
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = DieUIImageView(image: image!)
            dieImageView.frame = CGRect(x: 200 + (76 * index), y: 900, width: 64, height: 64)
            view.addSubview(dieImageView)
        }
    }
}
