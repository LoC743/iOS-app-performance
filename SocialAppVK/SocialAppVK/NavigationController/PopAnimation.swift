//
//  PopAnimation.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 27.10.2020.
//

import UIKit

class PopAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        transitionContext.containerView.sendSubviewToBack(destination.view)
        
        destination.view.frame = source.view.frame
        let translation = CGAffineTransform(translationX: source.view.frame.midX, y: source.view.frame.midY)
        let rotation = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        let backTranslation = CGAffineTransform(translationX: -source.view.frame.midX, y: -source.view.frame.midY)
        destination.view.transform = translation.concatenating(rotation).concatenating(backTranslation)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .calculationModePaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75) {
                let translation = CGAffineTransform(translationX: -source.view.frame.midX, y: source.view.frame.midY)
                let rotation = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                let backTranslation = CGAffineTransform(translationX: source.view.frame.midX, y: -source.view.frame.midY)
                
                source.view.transform = translation.concatenating(rotation).concatenating(backTranslation)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                destination.view.transform = .identity
            }
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
    }
}
