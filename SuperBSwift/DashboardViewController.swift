//
//  DashboardViewController.swift
//  SuperBSwift
//
//  Created by Nauroo on 01/05/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController,UIViewControllerTransitioningDelegate, MenuViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtontapped(_ sender: Any) {
        
    }

    //MARK: UIViewControllerAnimatedTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return DashboardTransitionAnimator(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return DashboardTransitionAnimator(presenting: false)
    }
    
    //Delegate Methods of MenuViewControllerDelegate
    func showLogout()
    {
        
    }
    
    func showCalendar()
    {
        
    }
    
    func showPendingJobs()
    {
        
    }
    func showCompletedJobs(){
        
    }
    
    func showAvailability(){
        
    }
    
    func showOpacityLayer()
    {
        let layer = CALayer()
        layer.name = "opacityLayer"
        layer.frame = view.bounds
        layer.backgroundColor = UIColor(white: 0.0, alpha: 0.3).cgColor
        view.layer.addSublayer(layer)
    }
    
    func hideOpacityLayer()
    {
        if let opacityLayer = view.layer.sublayers?.filter({$0.name == "opacityLayer"}).first
        {
            if let index = view.layer.sublayers?.index(of: opacityLayer)
            {
                view.layer.sublayers?.remove(at: index)
            }
        }
    }

}
