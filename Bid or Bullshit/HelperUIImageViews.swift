//
//  DieUIImageView.swift
//  Bid or Bullshit
//
//  Created by M.A. van der Velde on 13/03/17.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

/**
 Subclasses of UIImageView that allow identification of the views that are on screen.
 */


// Each die on the screen has its own DieUIImageView
class DieUIImageView: UIImageView {
    
    var owner: String? // The owner of the die, either the model or the human player
}

// Each dice cup has its own CupUIImageView
class CupUIImageView: UIImageView {
    
}
