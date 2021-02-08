//
//  NewsTableViewCell.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 16.10.2020.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    var avatarImageView: UIImageView = UIImageView()
    var nameLabel: UILabel = UILabel()
    
    var postDateLabel: UILabel = UILabel()
    var postTextLabel: UILabel = UILabel()
    
    var postImageView: UIImageView = UIImageView()
    
    var likeButton: UIButton = UIButton()
    var commentButton: UIButton = UIButton()
    var repostButton: UIButton = UIButton()
    
    var viewsImageView: UIImageView = UIImageView()
    var viewsCountLabel: UILabel = UILabel()
    
    var moreButton: UIButton = UIButton()
    var isExpanded: Bool = false
    var isExpandable: Bool = false
    
    var mainScreen: NewsTableViewController?
    
    private var screenBounds = UIScreen.main.bounds
    
    private var post: News?
    
    private let likeImage = UIImage(systemName: "heart.fill")!
    private let dislikeImage = UIImage(systemName: "heart")!
    
    private let maxHeight: CGFloat = 200
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        self.contentView.backgroundColor = Colors.background
        
        isExpanded = false
        isExpandable = false
    }
    
    private func setupAvatarImageView() {
        addSubview(avatarImageView)
        
        let frame = CGRect(
            x: 15,
            y: 15,
            width: 55,
            height: 55
        )
        avatarImageView.frame = frame
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = Colors.background
        avatarImageView.layer.cornerRadius = frame.height / 2
        avatarImageView.clipsToBounds = true
    }
    
    private func setupNameLabel() {
        addSubview(nameLabel)
        
        let avatarImageViewFrame = avatarImageView.frame
        let originX = avatarImageViewFrame.maxX + 15
        let frame = CGRect(
            x: originX,
            y: 15,
            width: screenBounds.width - originX - 15,
            height: 19
        )
        nameLabel.frame = frame
        nameLabel.textColor = Colors.text
        nameLabel.backgroundColor = Colors.background
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
    }
    
    private func setupDateLabel() {
        addSubview(postDateLabel)
        
        let nameLabelFrame = nameLabel.frame
        let frame = CGRect(
            x: nameLabelFrame.origin.x,
            y: nameLabelFrame.maxY + 5,
            width: nameLabelFrame.width,
            height: 16
        )
        postDateLabel.frame = frame
        postDateLabel.textColor = Colors.text
        postDateLabel.backgroundColor = Colors.background
        postDateLabel.font = .systemFont(ofSize: 13, weight: .light)
    }
    
    private func setupTextLabel(_ text: String) {
        addSubview(postTextLabel)
        
        postTextLabel.text = text
        postTextLabel.textAlignment = .natural
        postTextLabel.textColor = Colors.text
        postTextLabel.backgroundColor = Colors.background
        postTextLabel.numberOfLines = 0
        postTextLabel.font = .systemFont(ofSize: 14)
        postTextLabel.lineBreakMode = .byTruncatingTail
        
        layoutTextLabel(text: text)
    }
    
    private func layoutTextLabel(text: String) {
        isExpandable = false
        let avatarImageViewFrame = avatarImageView.frame
        
        if text.isEmpty {
            let origin = CGPoint(x: 10, y: avatarImageViewFrame.maxY + 10)
            postTextLabel.frame = CGRect(origin: origin, size: .zero)
        } else {
            let size = getLabelSize(label: postTextLabel)
            var height = size.height
            if size.height > maxHeight {
                height = maxHeight
                isExpandable = true
            }
            let frame = CGRect(
                x: 10,
                y: avatarImageViewFrame.maxY + 10,
                width: screenBounds.width - 20,
                height: height
            )
            postTextLabel.frame = frame
            
            if (isExpandable) {
                setupMoreButton()
            }
        }
    }

    private func setupMoreButton() {
        addSubview(moreButton)
        
        layoutMoreButton()
        
        moreButton.setTitle("Show more", for: .normal)
        moreButton.setTitleColor(Colors.brand, for: .normal)
        moreButton.tintColor = Colors.brand
        moreButton.backgroundColor = Colors.background
        moreButton.titleLabel?.font = .systemFont(ofSize: 15)
    }
    
    private func layoutMoreButton() {
        let postTextLabelFrame = postTextLabel.frame
        let frame = CGRect(
            x: screenBounds.maxX - 82,
            y: postTextLabelFrame.maxY - 5,
            width: 77,
            height: 30
        )
        moreButton.frame = frame
    }
    
    private func setupPostImageView(_ photo: VKImage) {
        addSubview(postImageView)
        
        layoutPostImageView(photo: photo)
        setPostImage(url: photo.url)
        
        postImageView.clipsToBounds = true
        postImageView.backgroundColor = Colors.background
        
        let imageTapped = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped))
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(imageTapped)
    }
    
    func setPostImage(url: String) {
        guard let url = URL(string: url) else {
            postImageView.isHidden = true
            return
        }
        postImageView.isHidden = false
        postImageView.kf.setImage(with: url)
    }
    
    private func layoutPostImageView(photo: VKImage) {
        let postTextLabelFrame = postTextLabel.frame
        
        var frameWidth: CGFloat = CGFloat(photo.width) > screenBounds.width ? screenBounds.width : CGFloat(photo.width)
        var frameHeight = frameWidth * photo.aspectRatio
        
        if frameHeight > screenBounds.height {
            frameWidth /= 1.5
            frameHeight /= 1.5
        }
        
        let frame = CGRect(
            x: screenBounds.midX - frameWidth/2,
            y: postTextLabelFrame.maxY + 25,
            width: frameWidth,
            height: frameHeight
        )
        postImageView.frame = frame
    }
    
    @objc func handleImageTapped() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoViewerViewController") as! PhotoViewerViewController
        
        guard let post = post,
              let photo = post.photo,
              let main = mainScreen else { return }
        
        let vkImage = VKImage(url: photo.url, height: photo.height, width: photo.width)
        let image = Image(vkImage: vkImage)
        
        vc.getPhotosData(photos: [image], currentIndex: 0)
        
        main.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLikeButton(_ numberOfLikes: String) {
        addSubview(likeButton)
        
        layoutLikeButton(numberOfLikes: numberOfLikes)
        
        likeButton.tintColor = .red
        likeButton.setTitle(numberOfLikes, for: .normal)
        likeButton.setTitleColor(Colors.text, for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 14)
        likeButton.backgroundColor = Colors.background
        likeButton.addTarget(self, action: #selector(likeButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layoutLikeButton(numberOfLikes: String) {
        let postImageViewFrame = postImageView.frame
        let frame = CGRect(
            x: 10,
            y: postImageViewFrame.maxY + 5,
            width: CGFloat(25 + numberOfLikes.count*10),
            height: 21
        )
        likeButton.frame = frame
    }
    
    private func setupCommentButton(_ numberOfComments: String) {
        addSubview(commentButton)
        
        layoutCommentButton(numberOfComments: numberOfComments)
        
        commentButton.setTitle(numberOfComments, for: .normal)
        commentButton.setImage(UIImage(systemName: "text.bubble")!, for: .normal)
        commentButton.tintColor = Colors.brand
        commentButton.setTitleColor(Colors.text, for: .normal)
        commentButton.titleLabel?.font = .systemFont(ofSize: 14)
        commentButton.backgroundColor = Colors.background
        commentButton.addTarget(self, action: #selector(commentButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layoutCommentButton(numberOfComments: String) {
        let likeButtonFrame = likeButton.frame
        let frame = CGRect(
            x: likeButtonFrame.maxX + 5,
            y: likeButtonFrame.origin.y,
            width: CGFloat(25 + numberOfComments.count*10),
            height: 22
        )
        commentButton.frame = frame
    }
    
    private func setupRepostButton(_ numberOfReposts: String) {
        addSubview(repostButton)
        
        layoutRepostButton(numberOfReposts: numberOfReposts)
        
        repostButton.setTitle(numberOfReposts, for: .normal)
        repostButton.setImage(UIImage(systemName: "arrowshape.turn.up.left")!, for: .normal)
        repostButton.tintColor = Colors.brand
        repostButton.setTitleColor(Colors.text, for: .normal)
        repostButton.titleLabel?.font = .systemFont(ofSize: 14)
        repostButton.backgroundColor = Colors.background
        repostButton.addTarget(self, action: #selector(repostButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func layoutRepostButton(numberOfReposts: String) {
        let commentButtonFrame = commentButton.frame
        let frame = CGRect(
            x: commentButtonFrame.maxX + 5,
            y: commentButtonFrame.origin.y,
            width: CGFloat(25 + numberOfReposts.count*10),
            height: 22
        )
        repostButton.frame = frame
    }
    
    private func setupViewsCountLabel(_ viewsCount: String) {
        addSubview(viewsCountLabel)
        addSubview(viewsImageView)
        
        layoutViewsCountLabel(viewsCount: viewsCount)
        
        viewsCountLabel.text = viewsCount
        viewsCountLabel.textColor = Colors.text
        viewsCountLabel.font = .systemFont(ofSize: 14)
        viewsCountLabel.backgroundColor = Colors.background
        
        viewsImageView.image = UIImage(systemName: "eye")
        viewsImageView.tintColor = Colors.brand
        viewsImageView.backgroundColor = Colors.background
    }
    
    private func layoutViewsCountLabel(viewsCount: String) {
        let likeButtonFrame = likeButton.frame
        let width = CGFloat(10 * viewsCount.count)
        let viewsCountLabelFrame = CGRect(
            x: screenBounds.maxX - width - 5,
            y: likeButtonFrame.origin.y,
            width: CGFloat(11 * viewsCount.count),
            height: 20
        )
        viewsCountLabel.frame = viewsCountLabelFrame
        layoutViewsImageView()
    }
    
    private func layoutViewsImageView() {
        let viewsCountLabelFrame = viewsCountLabel.frame
        let viewsImageViewFrame = CGRect(
            x: viewsCountLabelFrame.origin.x - 25,
            y: viewsCountLabelFrame.origin.y + 1,
            width: 21,
            height: 17
            
        )
        viewsImageView.frame = viewsImageViewFrame
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
    
    func setValues(item: News, group: Group) {
        self.post = item
        
        isExpanded = false
        isExpandable = false
        
        // Header новости
        setupAvatarImageView()
        setupNameLabel()
        setupDateLabel()
        
        if let photo = group.photo,
           let url = URL(string: photo.photo_100) {
            avatarImageView.kf.setImage(with: url)
        }
        nameLabel.text = group.name
        postDateLabel.text = getStringFromDate(item.date)
        
        // Наполнение новости
        setupTextLabel(item.text)
        
        if let photo = item.photo {
            setupPostImageView(photo)
        }
        
        // Footer новости
        setupLikeButton(String(item.likesCount))
        setLikeButtonState(isUserLikes: item.isUserLikes)
        setupCommentButton(String(item.repostsCount))
        setupRepostButton(String(item.commentCount))
        setupViewsCountLabel(String(item.viewsCount))
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
    
    @objc func likeButtonPressed(_ sender: UIButton) {
        changeLikeButtonImage()
    }
    
    @objc func commentButtonPressed(_ sender: UIButton) {
        print(#function)
    }
    
    @objc func repostButtonPressed(_ sender: UIButton) {
        print(#function)
    }
    
    func cellSize() -> CGSize {
        let width = screenBounds.width
        let height = likeButton.frame.maxY + 10

        return CGSize(width: width, height: height)
    }
    
    func expandLabel() -> Bool {
        guard isExpandable else { return false }
        if !isExpanded {
            // Если лейбл требуется раскрыть
            moreButton.setTitle("Show less", for: .normal)
            let size = getLabelSize(label: postTextLabel)
            postTextLabel.frame = CGRect(
                origin: postTextLabel.frame.origin,
                size: size
            )
        } else {
            // Лейбл требуется закрыть
            moreButton.setTitle("Show more", for: .normal)
            let size = CGSize(width: postTextLabel.frame.width, height: maxHeight)
            postTextLabel.frame = CGRect(
                origin: postTextLabel.frame.origin,
                size: size
            )
        }
        layoutViews()
        isExpanded = !isExpanded
        return isExpanded
    }
    
    private func layoutViews() {
        guard let item = post else { return }
        if let photo = item.photo {
            layoutPostImageView(photo: photo)
        }
        layoutMoreButton()
        layoutLikeButton(numberOfLikes: String(item.likesCount))
        layoutCommentButton(numberOfComments: String(item.commentCount))
        layoutRepostButton(numberOfReposts: String(item.repostsCount))
        layoutViewsCountLabel(viewsCount: String(item.viewsCount))
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
        let postTextFrame = postTextLabel.frame
        let maxWidth = postTextFrame.width
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let width = Double(rect.width)
        let height = Double(rect.height)
        return CGSize(width: ceil(width), height: ceil(height))
    }
}
