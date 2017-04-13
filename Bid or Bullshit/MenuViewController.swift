//
//  MenuViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var instructions: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundImage()
        
        // Adjust appearance of menu buttons
        start.layer.cornerRadius = 10
        start.contentEdgeInsets = UIEdgeInsets(top: 8, left: 100, bottom: 8, right: 100)
        
        instructions.layer.cornerRadius = 10
        instructions.contentEdgeInsets = UIEdgeInsets(top:8, left:45, bottom:8, right:45)
    }
    
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


    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}    

    @IBAction func saveSettingsAndReturnToMenu(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenuFromSettings", sender: self)
    }
}
