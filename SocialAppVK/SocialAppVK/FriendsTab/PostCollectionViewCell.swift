//
//  PostCollectionViewCell.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var post: Image?
    
    private let likeImage = UIImage(systemName: "heart.fill")!
    private let dislikeImage = UIImage(systemName: "heart")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .cyan
        
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
    }
    
    private func setupLikeButton() {
        guard let post = post else { return }
        
        if post.likes.userLikes == false {
            likeButton.setImage(dislikeImage, for: .normal)
        } else {
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    private func setDefaultImage() {
        if let image = UIImage(named: "default-profile") {
            imageView.image = image
        }
    }
    
    func setValues(item: Image) {
        post = item
        
        guard let image = item.photo200 else {
            setDefaultImage()
            return
        }
        
        imageView.kf.setImage(with: URL(string: image.url))
        
        setupLikeButton()
    }

    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let post = self.post else { return }

        if post.likes.userLikes == false {
            likeButton.setImage(likeImage, for: .normal)
        } else {
            likeButton.setImage(dislikeImage, for: .normal)
        }
        
        self.post?.likes.userLikes = !post.likes.userLikes
    }
}
