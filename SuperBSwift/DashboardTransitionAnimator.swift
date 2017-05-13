//
//  DashboardTransitionAnimator.swift
//  NaurooSitters
//
//  Created by Nauroo on 4/21/15.
//  Copyright © 2017 Manas. All rights reserved.
//

import UIKit

class DashboardTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning
{
    var presenting = false
    var duration = 0.3
    
    //MARK: Initializers
    convenience init(presenting: Bool, duration: Double = 0.3)
    {
        self.init()
        self.presenting = presenting
        self.duration = duration
    }
    
    //MARK: Configuration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return duration
    }
    
    //MARK: Transition from left to right (Sidebar)
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let fromVCFrame = transitionContext.initialFrame(for: fromVC!)
        var finalFrame = CGRect(origin: CGPoint.zero, size: fromVCFrame.size)
        
        if (presenting)
        {
            toVC!.view.frame.origin.x = -toVC!.view.frame.size.width
            transitionContext.containerView.addSubview(toVC!.view)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                toVC?.view.frame = finalFrame
                fromVC?.view.frame.origin.x = (toVC!.view.frame.width - 72)
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(true)
            }
        }
        else
        {
            
            toVC?.view.isUserInteractionEnabled = true
            
            finalFrame.origin.x = 0 //-toVC!.view.bounds.size.width
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                
                toVC?.view.tintAdjustmentMode = UIViewTintAdjustmentMode.automatic
                //fromVC?.view.frame.origin.x = 0
                fromVC?.view.frame.origin.x = -(fromVC?.view.frame.size.width)!
                toVC?.view.frame = finalFrame
                
            }, completion: { (finished: Bool) -> Void in
                transitionContext.completeTransition(true)
            })
        }
    }
}
















