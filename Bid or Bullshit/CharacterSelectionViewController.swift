//
//  CharacterSelectionViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 10/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit



struct OpponentCharacter {
    let name: String
    let difficulty: String
    let description: String
    let image: UIImage
}


class CharacterSelectionViewController: UIViewController {

    // CAPTAIN HOOK
    let captainHook = OpponentCharacter(
        name: "Captain Hook",
        difficulty: "easy",
        description: "The cunning commander of the pirate ship Jolly Roger, Captain Hook has an iron hook in place of one of his hands, which was eaten by a crocodile.",
        image: UIImage(named: "captainhook2")!
    )
    
    // DAVY JONES
    let davyJones = OpponentCharacter(
        name: "Davy Jones",
        difficulty: "intermediate",
        description: "As the ruler of the Seven Seas and the fearsome captain of the Flying Dutchman, Davy Jones strikes terror into the bravest of sailors.",
        image: UIImage(named: "davyjones")!
    )
    
    // CHING SHIH
    let chingShih = OpponentCharacter(
        name: "Ching Shih",
        difficulty: "expert",
        description: "Known as the Terror of South China, Ching Shih leads the formidable Red Flag Fleet, an invincible force of as much as 40,000 pirates.",
        image: UIImage(named: "chingshih2")!
    )
    
    var opponents: [OpponentCharacter]?
    var selectedOpponent: OpponentCharacter? = nil {
        didSet {
            self.performSegue(withIdentifier: "startGameWithCharacter", sender: self)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        opponents = [captainHook, davyJones, chingShih]
        addCharacterButtons()
        
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
    
    /**
     Adds a button for each opponent character to the screen.
     */
    private func addCharacterButtons() {
        
        
        for (index, opponent) in (opponents?.enumerated())! {
            let frame = CGRect(x: (242 * index) + 42, y: 312, width: 200, height: 400)
            createButton(name: opponent.name, description: opponent.description, difficulty: opponent.difficulty, frame: frame, image: opponent.image)
        }
    }
    
    
    /**
     Lays out the character's button. The button has a 450x450px image at the top, with the character's name, difficulty, and a short description below it.
     */
    private func createButton(name: String, description: String, difficulty: String, frame: CGRect, image: UIImage) {
        // Create button
        let btn = UIButton(type: .custom)
        btn.frame = frame
        btn.backgroundColor = UIColor.darkGray
        btn.tintColor = UIColor.white
        btn.layer.masksToBounds = false
        btn.layer.shadowOpacity = 0.8
        btn.layer.shadowRadius = 5
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.addTarget(self, action: #selector(CharacterSelectionViewController.didPressButton), for: .touchUpInside)
        
        // Add image
        btn.setImage(image, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 200, 0)    // top, left, bottom, right
        
        // Add title, difficulty, and description below the image
        let titleString = name
        let titleAttributedString = NSAttributedString(string: titleString, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 28), NSForegroundColorAttributeName: UIColor.white])
        
        let difficultyString = "\n(" + difficulty + ")"
        let difficultyAttributedString = NSAttributedString(string: difficultyString, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.white])
        
        let descriptionString = "\n\n" + description
        let descriptionAttributedString = NSAttributedString(string: descriptionString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white])
        
        let fullAttributedString = NSMutableAttributedString(attributedString: titleAttributedString)
        fullAttributedString.append(difficultyAttributedString)
        fullAttributedString.append(descriptionAttributedString)
        
        btn.setAttributedTitle(fullAttributedString, for: .normal)
        btn.titleEdgeInsets = UIEdgeInsetsMake(200, -445, 0, 5) // top, left, bottom, right
        btn.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        btn.titleLabel!.textAlignment = NSTextAlignment.center
        
        btn.setTitle(name, for: .reserved)
        
        // Add button to parent view
        self.view.addSubview(btn)

    }
    
    
    
    func didPressButton(sender: UIButton!) {
        if let buttonTitle = sender.title(for: .reserved) {
            if (opponents != nil) {
                for opponent in opponents! {
                    if (opponent.name == buttonTitle) {
                        selectedOpponent = opponent
                    }
                }
            }
        }
    }

    
    
    @IBAction func back(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMenuFromCharScreen", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        let destinationVC = segue.destination
        
        if let destinationVC = destinationVC as? GameViewController {
            // Pass the selected object to the new view controller.
            destinationVC.opponent = selectedOpponent!
        }
    }
 

}
