//
//  CustomNavigationController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 27.10.2020.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let interactive = CustomInteractiveTransition()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        navigationBar.backgroundColor = Colors.background
        navigationBar.barTintColor = Colors.background
        navigationBar.tintColor = Colors.brand
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.brand]
    }
    

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive.hasStarted ? interactive : nil
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == .pop {
            if navigationController.viewControllers.first != toVC {
                self.interactive.viewController = toVC
            }
            return PopAnimation()
        } else if operation == .push {
            self.interactive.viewController = toVC
            return PushAnimation()
        }

        return nil
    }
    
}
