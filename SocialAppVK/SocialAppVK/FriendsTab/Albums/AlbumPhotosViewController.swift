//
//  AlbumPhotosViewController.swift
//  SocialAppVK
//
//  Created by Alexey on 02.02.2021.
//

import AsyncDisplayKit

class AlbumPhotosViewController: ASDKViewController<ASCollectionNode> {
    var album: Album?
    
    private var images: [Image] = []
    private var collectionNode: ASCollectionNode
    
    override init() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.height / 4
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(node: collectionNode)
        
        collectionNode.backgroundColor = Colors.background
        collectionNode.dataSource = self
        collectionNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = album?.title
        collectionNode.view.isScrollEnabled = true
    }
    
    func loadPhotosFromAlbum() {
        guard let album = album else { return }
        
        NetworkManager.shared.getPhotosFrom(albumID: String(album.id), ownerID: String(album.ownerID)) { (imageList) in
            DispatchQueue.main.async {
                guard let imageList = imageList else { return }
                
                self.images = imageList.images
                self.collectionNode.reloadData()
            }
        } failure: { }
    }
}

extension AlbumPhotosViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoViewerViewController") as! PhotoViewerViewController
               
        vc.getPhotosData(photos: images, currentIndex: indexPath.item)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let image = images[indexPath.row]
        if let photo = image.photo200,
           let imageData = NetworkManager.shared.loadImageFrom(url: photo.url),
           let img = UIImage(data: imageData) {
            let cell = AsyncImageCellCollectionNode(with: img)
            return {
                return cell
            }
        }
        return {
            return ASCellNode()
        }
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}
