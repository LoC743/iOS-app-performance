//
//  GroupsCollectionViewController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 25.11.2020.
//

import UIKit
import RealmSwift
import FirebaseFirestore

class GroupsCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "PostCollectionViewCell"
    
    var groupData: Group!
    var posts: Results<Image>!
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        view.backgroundColor = Colors.background
        
        setupAddButton()
    }
    
    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        let groupsRef = db.collection("\(userID)-groups").document("\(groupData.id)")
        
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
        
        db.collection("\(userID)-groups").document("\(groupData.id)").delete() { err in
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
        
        db.collection("\(userID)-groups").document("\(groupData.id)").setData(groupData.toFirestore(), merge: true)
    }
    
    private func manageGroupInFirestore() {
        guard let userID = UserSession.instance.userID else { return }
        let db = Firestore.firestore()
        let groupsRef = db.collection("\(userID)-groups").document("\(groupData.id)")
        
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
    
    
    @objc func addButtonTapped() {
        manageGroupInFirestore()
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
        
        self.groupData = group
        self.posts = DatabaseManager.shared.loadImageDataBy(ownerID: groupID)
        self.token = posts.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update:
                self.collectionView.reloadData()
                break
            case .initial:
                self.collectionView.reloadData()
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        
        cell.setValues(item: posts[indexPath.item])
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoViewerViewController") as! PhotoViewerViewController
        
        let images: [Image] = posts.map { $0 }
        
        vc.getPhotosData(photos: images, currentIndex: indexPath.item)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
