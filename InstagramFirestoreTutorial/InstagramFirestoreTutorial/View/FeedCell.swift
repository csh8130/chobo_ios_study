//
//  FeedCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Choi SeungHyuk on 2021/04/05.
//

import UIKit

class FeedCell: UICollectionViewCell {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .purple
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
