//
//  InstructionsViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 11/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var instructions: UILabel!
    
    @IBAction func back(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenuFromInstructions", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
    }
    
    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "nauticalmap")
        backgroundImageView.alpha = 0.25
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
    }

}
