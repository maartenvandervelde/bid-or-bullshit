//
//  InstructionsContentViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 24/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class InstructionsContentViewController: UIViewController {
    
    @IBOutlet weak var instructionImage: UIImageView!
    
    @IBOutlet weak var instructionText: UILabel!
    
    var instruction: String?
    var image: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        instructionText.text = instruction!
        if image != nil {
            if let img = UIImage(named: image!) {
                instructionImage.image = img
            }
        }
    }
}
