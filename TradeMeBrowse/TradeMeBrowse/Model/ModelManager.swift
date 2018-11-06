//
//  ModelManager.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Alamofire
import AlamofireImage //using image cache

typealias JSONDict = Dictionary<String, Any>

extension String {
    static let baseURL          = "https://api.tmsandbox.co.nz/v1/"
    static let authorizationKey = "Authorization"
    static let subcategoriesKey = "Subcategories"
    static let nameKey          = "Name"
    static let numberKey        = "Number"
    static let pathKey          = "Path"
    static let leafKey          = "IsLeaf"
    static let totalCountKey    = "TotalCount"
    static let listKey          = "List"
    static let titleKey         = "Title"
    static let listingIdKey     = "ListingId"
    static let pictureHrefKey   = "PictureHref"
    static let priceKey         = "PriceDisplay"
    static let regionKey        = "Region"
    static let categoryKey      = "Category"
    static let photosKey        = "Photos"
    static let valueKey         = "Value"
    static let galleryKey       = "Gallery"
}

enum ModelError: Error {
    case emptyData
    case connectionFailed
}

class ModelManager: NSObject {

    static var shared = ModelManager()
    static let maximumCacheBytes = UInt64(100*1024*1024)
    static let preferredCacheBytes = maximumCacheBytes/2
    
    private var cachedImages = AutoPurgingImageCache(memoryCapacity: ModelManager.maximumCacheBytes, preferredMemoryUsageAfterPurge: ModelManager.preferredCacheBytes)
    
    /// request category with parameters number, rootLevel and depth(default to 1)
    func requestCategory(_ number: String, rootLevel: Int, depth: UInt = 1, completion: @escaping ([CategoryModel]) -> Void) {
        guard let url = URL(string: .baseURL + "Categories/\(number).json?depth=\(depth)") else { return }
        let queue = DispatchQueue(label: "com.category.trademe", qos: .background, attributes: .concurrent)
        
        Alamofire.request(url, method: .get)
            .responseJSON(queue: queue, completionHandler: { response in
                guard response.result.isSuccess else { return }
                guard let data = response.result.value as? JSONDict else { return }
                if let subcategories = data[.subcategoriesKey] as? Array<JSONDict> {
                    var models = [CategoryModel]()
                    subcategories.forEach {
                        models.append(self.transform($0, level: rootLevel+1))
                    }
                    completion(models)
                }
            })
    }
    
    /// transform raw data into a CategoryModel
    func transform(_ data: JSONDict, level: Int) -> CategoryModel {
        guard let name = data[.nameKey] as? String,
            let number = data[.numberKey] as? String,
            let path = data[.pathKey] as? String,
            let isLeaf = data[.leafKey] as? Bool
            else {
                return CategoryModel(number: "", name: "", path: "")
        }
        let model = CategoryModel(number: number, name: name, path: path, isLeaf: isLeaf)
        model.level = level
        return model
    }
    
    /// request data of listings with parameter category
    func requestSearchResults(in category: String, completion: @escaping (Result<[ListingModel]>) -> Void) {
        guard let url = URL(string: .baseURL + "Search/General.json?category=\(category)") else { return }
        let queue = DispatchQueue(label: "com.search.trademe", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .get,
                          headers:[.authorizationKey: authValue])
            .responseJSON(queue: queue, completionHandler: { response in
                guard response.result.isSuccess else { completion(Result.failure(ModelError.connectionFailed)); return }
                guard let data = response.result.value as? JSONDict else { completion(Result.failure(ModelError.connectionFailed)); return }
                guard let count = data[.totalCountKey] as? Int, count > 0 else { completion(Result.failure(ModelError.emptyData)); return }
                guard let list = data[.listKey] as? Array<JSONDict> else { completion(Result.failure(ModelError.connectionFailed)); return }
                
                var models = [ListingModel]()
                for index in 0..<min(count, 20) {
                    let model = self.transformList(list[index])
                    models.append(model)
                }
                completion(Result.success(models))
            })
    }
    
    private var timestamp: String {
        let timeInterval = Int(Date().timeIntervalSince1970)
        let timestamp = String(timeInterval)
        return timestamp
    }
    
    private var authValue: String {
        var auth = "OAuth "
        auth.append("oauth_consumer_key=\"A1AC63F0332A131A78FAC304D007E7D1\",")
        auth.append("oauth_token=\"206ED521E5552AB32EF768A2B1CCB64C\",")
        auth.append("oauth_signature_method=\"PLAINTEXT\",")
        auth.append("oauth_timestamp=\(timestamp)")
        auth.append("oauth_nonce=\"2rQiz7\",")
        auth.append("oauth_version=\"1.0\",")
        auth.append("oauth_signature=\"EC7F18B17A062962C6930A8AE88B16C7%261EB57D8A2A05AF0795F0FC17DD58C187\"")
        return auth
    }
    
    /// transform raw data into a ListingModel
    private func transformList(_ json: Dictionary<String, Any>) -> ListingModel {
        guard let name = json[.titleKey] as? String,
            let id = json[.listingIdKey] as? Int else { return ListingModel(name: "", id: 0, photoURL: nil) }
        let photoURL = json[.pictureHrefKey] as? String
        let model = ListingModel(name: name, id: id, photoURL: photoURL)
        return model
    }
    
    /// Returns a Request just in case that sometimes we want to cancel the request
    @discardableResult
    func requestImage(_ url: String, completion: @escaping (Result<UIImage>) -> Void = { _ in }) -> Request? {
        guard let imageURL = URL(string: url) else { return nil }
        let request = Alamofire.request(url)
        let queue = DispatchQueue(label: "com.thumbnail.trademe", qos: .background, attributes: .concurrent)
        DispatchQueue.global().async {
            Alamofire.request(imageURL).responseImage(queue: queue) { response in
                guard let image = response.result.value else { completion(Result.failure(ModelError.emptyData)); return }
                self.cachedImages.add(image, withIdentifier: url)
                completion(Result.success(image))
            }
        }
        
        return request
    }
    
    func cachedImage(_ url: String) -> Image? {
        return cachedImages.image(withIdentifier: url)
    }
    
    func requestItemDetails(_ listingId: String, completion: @escaping (Result<ItemDetailsModel>) -> Void) {
        guard let url = URL(string: .baseURL + "Listings/\(listingId).json") else { return }
        let queue = DispatchQueue(label: "com.listings.trademe", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .get,
                          headers:[.authorizationKey: authValue])
            .responseJSON(queue: queue, completionHandler: { response in
                guard response.result.isSuccess else { completion(Result.failure(ModelError.connectionFailed)); return }
                guard let data = response.result.value as? JSONDict else { completion(Result.failure(ModelError.connectionFailed)); return }
                guard let model = self.transformItemDetails(data) else { completion(Result.failure(ModelError.connectionFailed)); return }
                completion(Result.success(model))
            })
    }
    
    func transformItemDetails(_ json: JSONDict) -> ItemDetailsModel? {
        guard let listingId = json[.listingIdKey] as? Int,
            let title = json[.titleKey] as? String,
            let category = json[.categoryKey]  as? String,
            let price = json[.priceKey] as? String
        else { return nil }
        let region = json[.regionKey] as? String
        let item = ItemDetailsModel(listingId: listingId, title: title, category: category, price: price, region: region)
        if let photos = json[.photosKey] as? Array<JSONDict>,
            let first = photos.first,
            let value = first[.valueKey] as? JSONDict{
            item.photoHref = value[.galleryKey] as? String
        }
        return item
    }
}
