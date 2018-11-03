//
//  ListingModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation
import UIKit

class ListingModel {
    let name: String
    let id: String
    var photoURL: String?
    var photo: UIImage?
    
    init(name: String, id: String, photoURL: String?) {
        self.name = name
        self.id = id
        self.photoURL = photoURL
    }
}
