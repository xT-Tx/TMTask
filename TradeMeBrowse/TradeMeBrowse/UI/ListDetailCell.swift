//
//  ListDetailCell.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/4.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ListDetailCell: UICollectionViewCell {

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var ListingID: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    func startLoadingAnimation() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
