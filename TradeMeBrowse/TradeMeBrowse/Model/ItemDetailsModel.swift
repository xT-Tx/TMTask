//
//  ItemDetailsModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/6.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation
import Alamofire

class ItemDetailsModel: NSObject {

    let listingId: Int
    let title: String
    let category: String
    let priceDisplay: String
    let region: String?
    var photoHref: String?
    
    init(listingId: Int, title: String, category: String, price: String, region: String?) {
        self.listingId = listingId
        self.title = title
        self.category = category
        self.priceDisplay = price
        self.region = region
    }
    
    func fetchPhotoIfNecessary(_ completion: @escaping (Result<UIImage>) -> Void = { _ in }) {
        guard let url = photoHref else {
            completion(Result.failure(ModelError.emptyData))
            return
        }
        if let image = ModelManager.shared.cachedImage(url) {
            completion(Result.success(image))
        }
        else {
            ModelManager.shared.requestImage(url, completion: {
                result in
                completion(result)
            })
        }
    }
}
