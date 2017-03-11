//
//  MenuViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 04/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIPopoverPresentationControllerDelegate {

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


    
    // Present settings view as a popover
    @IBAction func openSettings(_ sender: UIButton) {
        let popover = storyboard?.instantiateViewController(withIdentifier: "Settings")
        popover?.modalPresentationStyle = UIModalPresentationStyle.popover
        popover?.popoverPresentationController?.delegate = self
        popover?.popoverPresentationController?.sourceView = self.view
        popover?.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popover?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        self.present(popover!, animated: true)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}    

    @IBAction func saveSettingsAndReturnToMenu(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenuFromSettings", sender: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
