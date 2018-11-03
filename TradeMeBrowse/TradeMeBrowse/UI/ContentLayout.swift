//
//  ContentLayout.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ContentLayout: UICollectionViewFlowLayout {

    static let marginPercent = CGFloat(0.05)
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let margin = collectionView.frame.size.width * ContentLayout.marginPercent
        sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        minimumLineSpacing = 20
        minimumInteritemSpacing = 20
    }
}
