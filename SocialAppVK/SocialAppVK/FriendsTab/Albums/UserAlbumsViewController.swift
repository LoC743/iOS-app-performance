//
//  UserAlbumsViewController.swift
//  SocialAppVK
//
//  Created by Alexey on 02.02.2021.
//

import AsyncDisplayKit

class UserAlbumsViewController: ASDKViewController<ASTableNode> {
    
    var owner: User?
    
    var tableNode: ASTableNode {
        node
    }
    private let reuseIdentifier = "AlbumCell"
    private var albums: [Album] = []

    override init() {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.title = "Альбомы"
    }
    
    func loadAlbums(user: User) {
        guard let user = owner else { return }

        NetworkManager.shared.getAlbums(ownerID: String(user.id)) { (albumList) in
            DispatchQueue.main.async {
                guard let albumList = albumList else { return }
                
                self.albums = albumList.albums
                self.tableNode.reloadData()
            }
        }
    }
}

extension UserAlbumsViewController: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return albums.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let data = albums[indexPath.section]
        
        let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
            
            let vc = AlbumPhotosViewController()
            vc.album = data
            vc.loadPhotosFromAlbum()
            return vc
        }, didLoad: nil)
        
        let size = CGSize(width: tableNode.bounds.size.width, height: tableNode.bounds.size.height/2)
        node.style.preferredSize = size
        
        return {
            return node
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return albums[section].title
    }
}
