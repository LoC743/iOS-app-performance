//
//  GroupImageCollectionViewCell.swift
//  SocialAppVK
//
//  Created by Alexey on 06.01.2021.
//

import UIKit

class GroupImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    private func setDefaultImage() {
        if let image = UIImage(named: "default-profile") {
            imageView.image = image
        }
    }
    
    func setValues(item: Image) {
        guard let image = item.photo200 else {
            setDefaultImage()
            return
        }
        
        imageView.kf.setImage(with: URL(string: image.url))
    }
}
