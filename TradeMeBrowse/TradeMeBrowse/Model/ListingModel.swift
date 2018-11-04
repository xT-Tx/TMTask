//
//  ListingModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ListingModel {
    let name: String
    let id: Int
    var photoURL: String?
    
    init(name: String, id: Int, photoURL: String?) {
        self.name = name
        self.id = id
        self.photoURL = photoURL
        fetchPhotoIfNecessary()
    }
    
    func fetchPhotoIfNecessary(_ completion: @escaping (UIImage) -> Void = { _ in }) {
        if let url = photoURL {
            if let image = ModelManager.shared.cachedImage(url) {
                completion(image)
                return
            }
            ModelManager.shared.requestImage(url, completion: {
                image in
                completion(image)
            })
        }
    }
}
