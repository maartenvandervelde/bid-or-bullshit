//
//  GameViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.delegate = self
        
        
        
    }

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

    
//    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
//        
//        let alert = UIAlertController(title: "Return to menu?", message: "Are you sure you want to return to the menu? Your progress in the game will be lost.", preferredStyle: .alert)
//        
//        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
//            if let navController = self.navigationController {
//                navController.popViewController(animated: true)
//            }
//
//        }
//        let noAction = UIAlertAction(title: "No", style: .cancel)
//        
//        alert.addAction(noAction)
//        alert.addAction(yesAction)
//        
//        //present(alert, animated: true, completion: nil)
//        present(alert, animated: true)
//    
//        return true
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
