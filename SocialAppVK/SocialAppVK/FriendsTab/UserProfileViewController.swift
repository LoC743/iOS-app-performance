//
//  UserProfileViewController.swift
//  SocialAppVK
//
//  Created by Alexey on 04.01.2021.
//

import UIKit
import RealmSwift

class UserProfileViewController: UIViewController {
    @IBOutlet weak var userProfileCollectionView: UICollectionView!
    
    let reuseIdentifier = "UserImageCollectionViewCell"
    
    var user: User!
    
    var userImages: Results<Image>!
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileCollectionView.register(UINib(nibName: "UserImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        userProfileCollectionView.register(UINib(nibName: "HeaderSectionCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderSectionCollectionReusableView")
        userProfileCollectionView.collectionViewLayout = setupCollectionViewLayout()
        userProfileCollectionView.delegate = self
        userProfileCollectionView.dataSource = self
        
        setupAlbumsButton()
    }
    
    private func setupAlbumsButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(albumButtonTapped))
    }
    
    @objc func albumButtonTapped() {
        let vc = UserAlbumsViewController()
        
        vc.owner = user
        vc.loadAlbums(user: user)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadImages(user: User, network: @escaping (ImageList?) -> Void) {
        NetworkManager.shared.getPhotos(ownerID: String(user.id), count: 30, offset: 0, type: .profile) { imageList in
            DispatchQueue.main.async {
                guard let imageList = imageList else { return }
                
                DatabaseManager.shared.saveImageData(images: imageList.images)
                
                network(imageList)
            }
        } failure: {  }
    }
    
    func getImages(user: User) {
        self.user = user
        
        self.userImages = DatabaseManager.shared.loadImageDataBy(ownerID: user.id)
        self.token = userImages.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update:
                self.userProfileCollectionView.reloadData()
                break
            case .initial:
                self.userProfileCollectionView.reloadData()
            case .error(let error):
                print("Error in \(#function). Message: \(error.localizedDescription)")
            }
        })
        
        loadImages(user: user) { (imageList) in
            DispatchQueue.main.async {
                if let imageList = imageList {
                    DatabaseManager.shared.saveImageData(images: imageList.images)
                }
            }
        }
    }
    
    private func getLastSeenDate(lastSeenUnix: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(lastSeenUnix))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy в HH:mm"
        let lastSeenString = formatter.string(from: date)
        
        return lastSeenString
    }
    
    private func getBirthDay() -> String? {
        guard let bday = user.birthDay else { return nil }
        
        let dateArray = bday.split(separator: ".")
        
        guard dateArray.count > 1 else { return nil }
        
        let monthInt = Int(dateArray[1]) ?? 1
        let monthStr = Calendar.current.monthSymbols[monthInt-1]
        
        var year = ""
        if dateArray.count > 2 {
            year = String(dateArray[2])
        }
        
        let result = "День рождения: \(dateArray[0]) \(monthStr) \(year)"
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderSectionCollectionReusableView", for: indexPath) as? HeaderSectionCollectionReusableView {
            sectionHeader.contentView.backgroundColor = Colors.background
            sectionHeader.profileImageView.roundView()
            sectionHeader.profileImageView.clipsToBounds = true
            sectionHeader.profileImageView.kf.setImage(with: URL(string: user.photo?.photo_200 ?? ""))
            
            sectionHeader.fullnameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            sectionHeader.fullnameLabel.textColor = Colors.text
            sectionHeader.fullnameLabel.text = user.name
            
            sectionHeader.statusLabel.font = .systemFont(ofSize: 14, weight: .light)
            if user.isOnline {
                sectionHeader.statusLabel.textColor = Colors.brand
                sectionHeader.statusLabel.text = "online"
            } else {
                let lastSeen = getLastSeenDate(lastSeenUnix: user.lastSeen)
                
                sectionHeader.statusLabel.textColor = Colors.text
                if user.gender == 1
                {
                    sectionHeader.statusLabel.text = "Была в сети \(lastSeen)"
                } else {
                    sectionHeader.statusLabel.text = "Был в сети \(lastSeen)"
                }
            }
            
            sectionHeader.additionalInfoLabel.font = .systemFont(ofSize: 15)
            sectionHeader.additionalInfoLabel.textColor = Colors.text
            
            var additionalInfo = ""
            if let city = user.city {
                additionalInfo += "Город: \(city.title)\n"
            }
            
            if let bday = getBirthDay() {
                additionalInfo += bday
            }
    
            sectionHeader.additionalInfoLabel.text = additionalInfo
            
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(125))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoViewerViewController") as! PhotoViewerViewController
        
        let images: [Image] = userImages.map { $0 }
        
        vc.getPhotosData(photos: images, currentIndex: indexPath.item)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserProfileViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 3

        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        return layout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserImageCollectionViewCell
        
        cell.setValues(item: userImages[indexPath.item])

    
        return cell
    }

}
