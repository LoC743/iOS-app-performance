//
//  HeaderSectionCollectionReusableView.swift
//  SocialAppVK
//
//  Created by Alexey on 04.01.2021.
//

import UIKit

class HeaderSectionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
}

extension UIImageView {
    func roundView() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
