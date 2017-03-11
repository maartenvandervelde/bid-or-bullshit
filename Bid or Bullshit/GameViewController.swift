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


class GameViewController: UIViewController {
    
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var gameInformation: UILabel!
    
    
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
    
    @IBAction func roll(_ sender: UIButton) {
        humanPlayer.rollDice()
        drawPlayerDice()
    }
    
    
    
    
    let diceImages = [1: UIImage(named: "die-1"),
                      2: UIImage(named: "die-2"),
                      3: UIImage(named: "die-3"),
                      4: UIImage(named: "die-4"),
                      5: UIImage(named: "die-5"),
                      6: UIImage(named: "die-6")]
    
    
    var opponent: OpponentCharacter? = nil
    
    let humanPlayer = HumanPlayer()
    let modelPlayer = ModelPlayer()
    
    
    
    
    private var gamestate = GameState.GameStart {
        didSet {
           // gameInformation.text = gamestate.rawValue
        }
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

    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "nauticalmap")
        backgroundImageView.alpha = 0.25
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }
    
    
    private func drawPlayerDice() {
        // Retrieve the player's current dice
        let playerDice = humanPlayer.diceList
        
        // Draw each die
        for (index, die) in playerDice.enumerated() {
            print(die)
            let image = diceImages[die] ?? UIImage(named: "grey-die-4")
            let dieImageView = UIImageView(image: image!)
            dieImageView.frame = CGRect(x: 200 + (76 * index), y: 900, width: 64, height: 64)
            view.addSubview(dieImageView)
        }
        
        
    }
    
    
    

}
