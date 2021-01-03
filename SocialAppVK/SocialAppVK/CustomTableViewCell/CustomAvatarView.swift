//
//  CustomAvatarView.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit
import Kingfisher

@IBDesignable class CustomAvatarView: UIView {
    
    @IBInspectable var shadowOpacity: Float = 0.8 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 8 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
        
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
        
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
