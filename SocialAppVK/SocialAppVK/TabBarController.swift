//
//  TabBarController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 01.10.2020.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = Colors.background
        tabBar.backgroundColor = Colors.background
        tabBar.tintColor = Colors.brand
    }
}
