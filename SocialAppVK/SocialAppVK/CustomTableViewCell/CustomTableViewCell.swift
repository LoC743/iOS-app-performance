//
//  CustomTableViewCell.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
//    @IBOutlet weak var avatarView: CustomAvatarView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var statusLabel: UILabel!
    
    var avatarView: CustomAvatarView = CustomAvatarView()
    var nameLabel: UILabel = UILabel()
    var statusLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - Setup cell UI
    
    func setupCell() {
        contentView.backgroundColor = Colors.background
        
        setupAvatarView()
        setupNameLabel()
    }
    
    func setupAvatarView() {
        addSubview(avatarView)
        let avatarViewFrame = CGRect(
            x: 10,
            y: 10,
            width: 55,
            height: 55)
        
        avatarView.frame = avatarViewFrame
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.avatarViewTapped(_:)))
        avatarView.addGestureRecognizer(tap)
        
    }
    
    @objc func avatarViewTapped(_ sender: UITapGestureRecognizer) {
        animateAvatarView()
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        let avatarViewFrame = avatarView.frame
        let nameLabelFrameX = avatarViewFrame.maxX + 25
        let nameLabelFrame = CGRect(
            x: nameLabelFrameX,
            y: 15,
            width: bounds.maxX - nameLabelFrameX - 10,
            height: 17)
        
        nameLabel.frame = nameLabelFrame
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    func setupStatusLabel() {
        addSubview(statusLabel)
        let nameLabelFrame = nameLabel.frame
        let statusLabelFrame = CGRect(
            x: nameLabelFrame.origin.x,
            y: nameLabelFrame.maxY + 7,
            width: bounds.maxX - nameLabelFrame.origin.x - 10,
            height: 16)
        
        statusLabel.frame = statusLabelFrame
        statusLabel.font = .systemFont(ofSize: 13, weight: .light)
    }

    
    // MARK: - Setup cell with data
    
    private func getLastSeenDate(lastSeenUnix: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(lastSeenUnix))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy в HH:mm"
        let lastSeenString = formatter.string(from: date)
        
        return lastSeenString
    }
    
    private func setStatusLabel(_ friend: User) {
        setupStatusLabel()
        if friend.isOnline {
            statusLabel.textColor = Colors.brand
            statusLabel.text = "online"
        } else {
            let lastSeen = getLastSeenDate(lastSeenUnix: friend.lastSeen)
            
            statusLabel.textColor = Colors.text
            if friend.gender == 1
            {
                statusLabel.text = "Была в сети \(lastSeen)"
            } else {
                statusLabel.text = "Был в сети \(lastSeen)"
            }
        }
    }
    
    private func setValues(item: CellModel) {
        if let photo = item.photo,
           let url = URL(string: photo.photo_100) {
            avatarView.setImage(url)
        }  else { avatarView.setDefaultImage() }
        
        nameLabel.text = item.name
    }
    
    func setFriendCell(friend: User) {
        setStatusLabel(friend)
//        setValues(item: friend) // OLD
        
        nameLabel.text = friend.name // NEW
    }
     
    func setGroupCell(group: Group) {
        statusLabel.isHidden = true
        setValues(item: group)
    }
    
    // MARK: - Animation
    
    private func animateAvatarView() {
        UIView.animate(withDuration: 1.3, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.autoreverse]) {
            self.avatarView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { (state) in
            self.avatarView.transform = .identity
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
