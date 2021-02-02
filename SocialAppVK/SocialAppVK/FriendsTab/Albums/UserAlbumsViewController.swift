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
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        // Open vc with photo collection
        print(albums[indexPath.row])
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func configureCell(indexPath: IndexPath) -> AsyncAlbumTableNodeCell {
        let data = albums[indexPath.row]
        let cell = AsyncAlbumTableNodeCell(titleText: data.title)
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock = { [weak self] () -> ASCellNode in
            guard let self = self else { return ASCellNode() }
            return self.configureCell(indexPath: indexPath)
        }
        return cellNodeBlock
    }
}
