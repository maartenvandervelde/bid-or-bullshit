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
    
    
    
    
    
    private var humanPlayer = HumanPlayer()
    private var modelPlayer = ModelPlayer()
    
    private var gamestate = GameState.GameStart {
        didSet {
           // gameInformation.text = gamestate.rawValue
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamestate = GameState.GameStart
        
        gameInformation.layer.borderWidth = 1
        gameInformation.backgroundColor = UIColor.lightGray
        
    }

    
    
    
    

}
