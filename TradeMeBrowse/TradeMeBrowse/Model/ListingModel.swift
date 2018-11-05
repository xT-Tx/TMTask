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
        if photoURL != nil {
            fetchPhotoIfNecessary()
        }
    }
    
    func fetchPhotoIfNecessary(_ completion: @escaping (UIImage?) -> Void = { _ in }) {
        guard let url = photoURL else {
            completion(nil)
            return
        }
        if let image = ModelManager.shared.cachedImage(url) {
            completion(image)
        }
        else {
            ModelManager.shared.requestImage(url, completion: {
                image in
                completion(image)
            })
        }
    }
}
