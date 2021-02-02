//
//  AsyncAlbumTableNodeCell.swift
//  SocialAppVK
//
//  Created by Alexey on 02.02.2021.
//

import AsyncDisplayKit

class AsyncAlbumTableNodeCell: ASCellNode {
    private let titleNode = ASTextNode()
    private let titleText: String
    
    init(titleText: String) {
        self.titleText = titleText
        
        super.init()
        backgroundColor = Colors.background
        
        setupSubnodes()
    }
    
    private func setupSubnodes() {
        titleNode.attributedText = NSAttributedString(string: titleText, attributes: [.font : UIFont.systemFont(ofSize: 17)])
        titleNode.backgroundColor = .clear
        addSubnode(titleNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleNodeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        let titleNodeLayout = ASInsetLayoutSpec(insets: titleNodeInsets, child: titleNode)
        return titleNodeLayout
    }
}
