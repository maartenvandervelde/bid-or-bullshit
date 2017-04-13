//
//  InstructionsViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 24/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    // container for the PageViewController
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Give the container view and back button rounded corners
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        backButton.layer.cornerRadius = 10
        backButton.contentEdgeInsets = UIEdgeInsets(top:8, left:20,bottom:8,right:20)
        
        setBackgroundImage()
    }
    
    /**
     Set the map image as the background of the view.
     */
    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "paper")
        backgroundImageView.alpha = 0.75
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }
    
    /**
     Return to menu when the user presses Back
    */
    @IBAction func back(_ sender: UIButton) {
    self.performSegue(withIdentifier: "unwindToMenuFromInstructions", sender: self)
    }
}
