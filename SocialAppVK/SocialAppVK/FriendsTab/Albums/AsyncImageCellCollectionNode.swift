//
//  AsyncImageCellCollectionNode.swift
//  SocialAppVK
//
//  Created by Alexey on 02.02.2021.
//

import AsyncDisplayKit

class AsyncImageCellCollectionNode: ASCellNode {
    let imageNode = ASImageNode()
    
    required init(with image: UIImage) {
        super.init()
    
        imageNode.contentMode = .scaleAspectFill
        imageNode.image = image
        self.addSubnode(self.imageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let imageNodeLayout = ASInsetLayoutSpec(insets: imageNodeInsets, child: imageNode)
        return imageNodeLayout
    }
}
