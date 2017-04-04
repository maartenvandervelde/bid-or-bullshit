//
//  InstructionsPageViewController.swift
//  Bid or Bullshit
//
//  Created by maarten on 24/03/2017.
//  Copyright © 2017 M.A. van der Velde. All rights reserved.
//

import UIKit

class InstructionsPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    let pages = [0,1,2,3,4]
    let textInstructions = [
    "First choose an opponent. Note that they have different difficulty levels.",
    "During game play, important information about the state of the game will be shown in this text box.",
    "Each player starts with five dice. You can only see your own dice. Players alternate in making bids, in which they claim that there are a certain number of a particular kind of die in the game. For example, you might claim that there are two sixes.",
    "Enter a bid using the highlighted buttons. When making an opening bid you can bid anything you want, but subsequent bids are constrained by a number of rules. The Bid button will only be enabled when the bid you have entered follows these rules. A legal bid increases the number of dice by 1, the number of pips by 1, both the number of dice and the number of pips by 1, or increases the number of dice by 1 while decreasing the number of pips by 1.",
    "When you don't believe a bid made by your opponent, call their bluff by hitting the Bullsh!t button. All dice will be revealed to evaluate the bid. If your opponent was indeed bluffing, they lose one of their dice. However, if the bid was correct, you lose a die instead. Be careful: the model can also call Bullsh!t on your bids! The last player to have dice remaining wins the game."
    ]
    
    let images = [
    "instruction0",
    "instruction5",
    "instruction1",
    "instruction2",
    "instruction3"
    ]
    
    var pageContentViews: [InstructionsContentViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        // Add the page contents
        for page in pages {
            let instructionsPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InstructionsContentViewController") as! InstructionsContentViewController
            
            instructionsPage.instruction = textInstructions[page]
            instructionsPage.image = images[page]
            pageContentViews.append(instructionsPage)
        }
        
        
        // Start on the first page
        if let firstViewController = pageContentViews.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = presentationIndex(for: pageViewController)
        
        let previousIndex = currentIndex - 1
        
        // If we are already at the first view, we cannot move backwards further
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pageContentViews[previousIndex]
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = presentationIndex(for: pageViewController)
        
        let nextIndex = currentIndex + 1
                
        // If we are already at the last view, we cannot move forwards further
        guard nextIndex < pageContentViews.count else {
            return nil
        }
        
        return pageContentViews[nextIndex]
    }
    
    

    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageContentViews.count
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewControllerIndex = pageContentViews.index(of: viewControllers?.first as! InstructionsContentViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
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
