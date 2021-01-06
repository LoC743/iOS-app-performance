//
//  GroupProfileViewController.swift
//  SocialAppVK
//
//  Created by Alexey on 06.01.2021.
//

import UIKit
import RealmSwift
import FirebaseFirestore

class GroupProfileViewController: UIViewController {
    
    @IBOutlet weak var groupProfileCollectionView: UICollectionView!
    
    let reuseIdentifierCell = "GroupImageCollectionViewCell"
    let reuseIdentifierHeader = "HeaderGroupSectionCollectionReusableView"
    
    var group: Group!
    
    var groupImages: Results<Image>!
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background
        setupAddButton()
        
        groupProfileCollectionView.register(UINib(nibName: "GroupImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierCell)
        groupProfileCollectionView.register(UINib(nibName: reuseIdentifierHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseIdentifierHeader)
        groupProfileCollectionView.collectionViewLayout = setupCollectionViewLayout()
        groupProfileCollectionView.delegate = self
        groupProfileCollectionView.dataSource = self
    }
    
    @objc func addButtonTapped() {
        manageGroupInFirestore()
    }
    
    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        let groupsRef = db.collection("\(userID)-groups").document("\(group.id)")
        
        groupsRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                self.navigationItem.rightBarButtonItem?.title = "Remove"
            } else {
                self.navigationItem.rightBarButtonItem?.title = "Add"
            }
        }
    }
    
    private func removeGroupGromFirestore() {
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        
        db.collection("\(userID)-groups").document("\(group.id)").delete() { err in
            if let err = err {
                print("[Firebase]: Error removing document: \(err)")
            } else {
                print("[Firebase]: Document successfully removed!")
            }
        }
    }
    
    private func saveGroupToFirestore() {
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        
        db.collection("\(userID)-groups").document("\(group.id)").setData(group.toFirestore(), merge: true)
    }
    
    private func manageGroupInFirestore() {
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        let groupsRef = db.collection("\(userID)-groups").document("\(group.id)")
        
        groupsRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                self.navigationItem.rightBarButtonItem?.title = "Add"
                self.removeGroupGromFirestore()
            } else {
                self.navigationItem.rightBarButtonItem?.title = "Remove"
                self.saveGroupToFirestore()
            }
        }
    }
    
    private func loadImages(group: Group, network: @escaping (ImageList?) -> Void) {
        let groupID: Int = Int(-group.id)
        NetworkManager.shared.getPhotos(ownerID: String(groupID), count: 30, offset: 0, type: .wall) { imageList in
            DispatchQueue.main.async {
                guard let imageList = imageList else { return }

                DatabaseManager.shared.saveImageData(images: imageList.images)
                
                network(imageList)
            }
        } failure: {  }
    }
    
    func getImages(group: Group) {
        let groupID: Int = Int(-group.id)
        
        self.group = group
        self.groupImages = DatabaseManager.shared.loadImageDataBy(ownerID: groupID)
        self.token = groupImages.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update:
                self.groupProfileCollectionView.reloadData()
                break
            case .initial:
                self.groupProfileCollectionView.reloadData()
            case .error(let error):
                print("Error in \(#function). Message: \(error.localizedDescription)")
            }
        })
        
        loadImages(group: group) { (imageList) in
            DispatchQueue.main.async {
                   if let imageList = imageList {
                    DatabaseManager.shared.saveImageData(images: imageList.images)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierHeader, for: indexPath) as? HeaderGroupSectionCollectionReusableView {
            sectionHeader.profileImageView.roundView()
            sectionHeader.profileImageView.clipsToBounds = true
            sectionHeader.profileImageView.kf.setImage(with: URL(string: group.photo?.photo_200 ?? ""))
            
            sectionHeader.nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            sectionHeader.nameLabel.textColor = Colors.text
            sectionHeader.nameLabel.text = group.name
            
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
        
        let images: [Image] = groupImages.map { $0 }
        
        vc.getPhotosData(photos: images, currentIndex: indexPath.item)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension GroupProfileViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
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
        return groupImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCell, for: indexPath) as! GroupImageCollectionViewCell
        
        cell.setValues(item: groupImages[indexPath.item])

    
        return cell
    }

}

