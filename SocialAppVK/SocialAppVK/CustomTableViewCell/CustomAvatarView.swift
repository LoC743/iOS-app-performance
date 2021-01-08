//
//  CustomAvatarView.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit
import Kingfisher

class CustomAvatarView: UIView {
    lazy var imageView: UIImageView = {
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var view: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        view.backgroundColor = Colors.background
        view.layer.cornerRadius = view.frame.height / 2
        
        view.layer.shadowColor = Colors.brand.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.8
        
        return view
    }()
    
    override func draw(_ rect: CGRect) {
        self.addSubview(view)
        self.addSubview(imageView)
    }
    
    func setImage(_ url: URL) {
        imageView.kf.setImage(with: url)
        
        if imageView.image == nil {
            setDefaultImage()
        }
    }
    
    func setDefaultImage() {
        if let image = UIImage(named: "default-profile") {
            imageView.image = image
        }
    }
}
