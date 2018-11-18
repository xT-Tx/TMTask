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
    @IBOutlet var disclosureButton: UIButton!
    
    @IBOutlet var buttonWidthConstraint: NSLayoutConstraint!
    
    @IBAction func buttonTapped(_ sender: Any) {
        disclosureDelegate?.openDisclosure(self)
    }
    
    weak var disclosureDelegate: CellDisclosureDelegate?
    
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
                layer.shadowRadius = 4.0
                layer.shadowOpacity = 0.85
                layer.shadowOffset = CGSize(width: 0, height: 1.0)
                layer.shadowColor = UIColor.black.cgColor
            }
            else {
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
                layer.shadowOffset = CGSize.zero
                layer.shadowColor = nil
            }
        }
    }
    
    var level = 1
    
    var isDisclosureEnabled: Bool = true {
        didSet {
            disclosureButton.isHidden = !isDisclosureEnabled
            buttonWidthConstraint.constant = (isDisclosureEnabled ? 46 : 0)
        }
    }
}

protocol CellDisclosureDelegate: class {
    func openDisclosure(_ sender: CategoryCell)
}
