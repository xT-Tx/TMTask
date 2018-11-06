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
    static let lineSpace = CGFloat(20)
    static let columnSpace = CGFloat(20)
    
    private var itemsAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    private var cvContentSize = CGSize.zero
    
    func collectionViewContentChanged() {
        itemsAttributes.removeAll()
        prepare()
    }
    
    // MARK: - UICollectionViewLayout delegate methods
    override var collectionViewContentSize: CGSize {
        return cvContentSize
    }
    
    override func prepare() {
        guard let cv = collectionView else { return }
        let margin = cv.frame.size.width * ContentLayout.marginPercent
        sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        minimumLineSpacing = ContentLayout.lineSpace
        minimumInteritemSpacing = ContentLayout.columnSpace
        
        guard let dataSource = cv.dataSource else { return }
        guard let delegateFlowLayout = cv.delegate as? UICollectionViewDelegateFlowLayout else { return }
        let numberOfItems = dataSource.collectionView(cv, numberOfItemsInSection: 0)
        var xOffset: CGFloat = margin
        var yOffset: CGFloat = margin
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        var prevSize = CGSize.zero
        cvContentSize.width = cv.bounds.size.width
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            if let itemSize = delegateFlowLayout.collectionView?(cv, layout: self, sizeForItemAt: indexPath) {
                cellWidth = itemSize.width
                cellHeight = itemSize.height
                
                let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                if xOffset + cellWidth > cv.bounds.size.width - margin || (prevSize != .zero && prevSize != itemSize) {
                    xOffset = margin
                    yOffset += prevSize.height + minimumLineSpacing
                }
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
                itemsAttributes.append(attributes)
                
                //increase xOffset for next cell.
                xOffset += cellWidth + minimumInteritemSpacing
                prevSize = itemSize
            }
        }
        cvContentSize.height = yOffset + prevSize.height + margin
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemsAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = itemsAttributes[indexPath.item]
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
