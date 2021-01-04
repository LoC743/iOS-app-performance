//
//  CustomTableViewCell.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarView: CustomAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = Colors.background
        
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 13, weight: .light)
        
        setupAvatarView()
    }
    
    private func getLastSeenDate(lastSeenUnix: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(lastSeenUnix))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy в hh:mm"
        let lastSeenString = formatter.string(from: date)
        
        return lastSeenString
    }
    
    private func setStatusLabel(_ friend: User) {
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
    
    func setFriendCell(friend: User) {
        setStatusLabel(friend)
        setValues(item: friend)
    }
        
    func setValues(item: CellModel) {
        if let photo = item.photo,
           let url = URL(string: photo.photo_100) {
            avatarView.setImage(url)
        }  else { avatarView.setDefaultImage() }
        
        nameLabel.text = item.name
    }
    
    func setupAvatarView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.avatarViewTapped(_:)))
        avatarView.addGestureRecognizer(tap)
    }
    
    @objc func avatarViewTapped(_ sender: UITapGestureRecognizer) {
        animateAvatarView()
    }
    
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
