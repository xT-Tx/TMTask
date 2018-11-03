//
//  CategoryModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation

struct CategoryModel {
    let number: String
    let name: String
    let path: String
    let isLeaf: Bool
    var subCategories: Array<CategoryModel> = [CategoryModel]()
    var list: Array<ListingModel>?
    
    init(number: String, name: String, path: String, isLeaf: Bool = false) {
        self.number = number
        self.name = name
        self.path = path
        self.isLeaf = isLeaf
    }
}
