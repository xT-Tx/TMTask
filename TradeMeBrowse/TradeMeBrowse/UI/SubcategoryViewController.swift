//
//  SubcategoryViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class SubcategoryViewController: UIViewController {

    var parentCategory: CategoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = parentCategory?.name
    }
}
