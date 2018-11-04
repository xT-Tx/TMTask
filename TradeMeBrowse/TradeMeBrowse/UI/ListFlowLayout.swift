//
//  ListFlowLayout.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/4.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ListFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
    }
}
