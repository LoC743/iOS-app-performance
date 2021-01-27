//
//  NewsTableViewCell.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 16.10.2020.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    var textHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var repostButton: UIButton!
    
    @IBOutlet weak var viewsImageView: UIImageView!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    private var isExpanded: Bool = false
    
    private var post: News?
    
    private let likeImage = UIImage(systemName: "heart.fill")!
    private let dislikeImage = UIImage(systemName: "heart")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = Colors.background
        setupView()
    }
    
    private func setupView() {
        self.contentView.backgroundColor = Colors.background
        setupAvatarImageView()
        setupNameLabel()
        setupDateLabel()
        setupPostImageView()
        setupTextLabel()
        setupLikeButton()
        setupCommentButton()
        setupRepostButton()
        setupViewsCountLabel()
        setupMoreButton()
        
        textHeightConstraint?.isActive = false
        isExpanded = false
    }
    
    private func setupAvatarImageView() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = Colors.background
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    private func setupNameLabel() {
        nameLabel.textColor = Colors.text
        nameLabel.backgroundColor = Colors.background
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
    }
    
    private func setupDateLabel() {
        postDateLabel.textColor = Colors.text
        postDateLabel.backgroundColor = Colors.background
        postDateLabel.font = .systemFont(ofSize: 13, weight: .light)
    }
    
    private func setupPostImageView() {
//        postImageView.contentMode = .scaleAspectFit
        postImageView.backgroundColor = Colors.background
    }
    
    private func setupTextLabel() {
        postTextLabel.textAlignment = .natural
        postTextLabel.textColor = Colors.text
        postTextLabel.backgroundColor = Colors.background
        postTextLabel.numberOfLines = 0
        postTextLabel.font = .systemFont(ofSize: 14)
    }
    
    private func setupLikeButton() {
        likeButton.backgroundColor = Colors.background
    }
    
    private func setupCommentButton() {
        commentButton.backgroundColor = Colors.background
    }
    
    private func setupRepostButton() {
        repostButton.backgroundColor = Colors.background
    }
    
    private func setupViewsCountLabel() {
        viewsImageView.backgroundColor = Colors.background
        viewsCountLabel.backgroundColor = Colors.background
    }
    
    private func setupMoreButton() {
        moreButton.isHidden = true
        moreButton.setTitle("Show more", for: .normal)
        moreButton.titleLabel?.textColor = Colors.brand
        moreButton.tintColor = Colors.brand
    }
    
    private func getStringFromDate(_ unixTimestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let string = dateFormatter.string(from: date)
        
        return string
    }
    
    private func changeLikeButtonImage() {
        guard let post = post else { return }
        
        if post.isUserLikes {
            likeButton.setImage(dislikeImage, for: .normal)
            self.post?.likesCount -= 1
        } else {
            likeButton.setImage(likeImage, for: .normal)
            self.post?.likesCount += 1
        }
        
        self.post?.isUserLikes = !post.isUserLikes
        let likesCount = String(self.post?.likesCount ?? 0)
        self.likeButton.setTitle(likesCount, for: .normal)
    }
    
    func setPostImage(url: String) {
        guard let url = URL(string: url) else {
            postImageView.isHidden = true
            return
        }
        postImageView.isHidden = false
        postImageView.kf.setImage(with: url)
    }
    
    func setValues(item: News, group: Group) {
        self.post = item
        
        if let photo = group.photo,
           let url = URL(string: photo.photo_100) {
            avatarImageView.kf.setImage(with: url)
        }
        
        nameLabel.text = group.name
        
        postDateLabel.text = getStringFromDate(item.date)
        
        postTextLabel.text = item.text
        if !item.text.isEmpty {
            setupExpandableLabel(text: item.text)
        } else {
            moreButton.isHidden = true
            textHeightConstraint?.isActive = false
        }
        
        if let photo = item.photo {
            setPostImage(url: photo.url)
        }
        
        likeButton.setTitle(String(item.likesCount), for: .normal)
        repostButton.setTitle(String(item.repostsCount), for: .normal)
        commentButton.setTitle(String(item.commentCount), for: .normal)
        
        viewsCountLabel.text = String(item.viewsCount)
        
        setLikeButtonState(isUserLikes: item.isUserLikes)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setLikeButtonState(isUserLikes: Bool) {
        if isUserLikes {
            likeButton.setImage(likeImage, for: .normal)
        } else {
            likeButton.setImage(dislikeImage, for: .normal)
        }
    }
    
    private func setNewLikeValueWithAnimation(post: News) {
        UIView.transition(with: likeButton, duration: 0.8, options: [.curveEaseOut, .transitionCurlUp]) {
            self.likeButton.setTitle(String(post.likesCount), for: .normal)
        } completion: { (state) in }
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        changeLikeButtonImage()
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        print(#function)
    }
    
    @IBAction func repostButtonPressed(_ sender: UIButton) {
        print(#function)
    }
    
    private func setupExpandableLabel(text: String) {
        let labelSize = getLabelSize(label: postTextLabel)
        let maxHeight: CGFloat = 100
        if labelSize.height > maxHeight && text.count > 1 {
            textHeightConstraint = postTextLabel.heightAnchor.constraint(equalToConstant: 100)
            textHeightConstraint?.isActive = true
            moreButton.frame = CGRect(x: postTextLabel.frame.minX,
                                      y: postTextLabel.frame.maxY + 10,
                                      width: 35,
                                      height: 16)
            moreButton.isHidden = false
        } else {
            moreButton.isHidden = true
            postTextLabel.heightAnchor.constraint(equalToConstant: maxHeight).isActive = false
        }
    }

    @IBAction func moreButtonTapped(_ sender: Any) {
        if isExpanded {
            textHeightConstraint?.isActive = true
            moreButton.setTitle("Show more", for: .normal)
        } else {
            textHeightConstraint?.isActive = false
            moreButton.setTitle("Show less", for: .normal)
        }
        isExpanded = !isExpanded
    }
    
    private func getLabelSize(label: UILabel) -> CGSize {
        let labelSize: CGSize
        if let labelText = label.text, !labelText.isEmpty {
            labelSize = getLabelSize(text: labelText as NSString, font: label.font)
        } else {
            labelSize = .zero
        }
        return labelSize
    }
    
    private func getLabelSize(text: NSString, font: UIFont) -> CGSize {
        let maxWidth = postTextLabel.frame.width
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let width = Double(rect.width)
        let height = Double(rect.height)
        return CGSize(width: ceil(width), height: ceil(height))
    }
}
