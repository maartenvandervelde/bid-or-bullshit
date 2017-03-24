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
    "First choose an opponent.",
    "How to enter a bid.",
    "Calling bullshit.",
    "End of the round.",
    "You win the game if you are the last player with dice."
    ]
    let images = [
    "davyjones",
    "davyjones",
    "davyjones",
    "davyjones",
    "davyjones"
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
