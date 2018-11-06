//
//  CategoryCell.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5.0
    }

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                layer.borderColor = UIColor.black.cgColor
                layer.borderWidth = 2.0
            }
            else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
    
    var level = 1 {
        didSet {
            let font = UIFont.boldSystemFont(ofSize: 20)
            switch level {
            case 1:
                name.font = font
            case 2:
                name.font = font.withSize(17)
            case 3:
                name.font = font.withSize(15)
            default:
                name.font = font.withSize(12)
            }
        }
    }
}
