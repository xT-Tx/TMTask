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
    static let authorizationKey = "Authorization"
}

class ModelManager: NSObject {

    static var shared = ModelManager()
    static let maximumCacheBytes = UInt64(100*1024*1024)
    static let preferredCacheBytes = maximumCacheBytes/2
    
    private var cachedImages = AutoPurgingImageCache(memoryCapacity: ModelManager.maximumCacheBytes, preferredMemoryUsageAfterPurge: ModelManager.preferredCacheBytes)
    
    /// request category with parameters number and depth(default to 1)
    func requestCategory(_ number: String, depth: UInt = 1, completion: @escaping ([CategoryModel]) -> Void) {
        guard let url = URL(string: "https://api.tmsandbox.co.nz/v1/Categories/\(number).json?depth=\(depth)") else { return }
        let queue = DispatchQueue(label: "com.category.trademe", qos: .background, attributes: .concurrent)
        
        Alamofire.request(url, method: .get)
            .responseJSON(queue: queue, completionHandler: { response in
                guard response.result.isSuccess else { return }
                guard let data = response.result.value as? JSONDict else { return }
                if let subcategories = data["Subcategories"] as? Array<JSONDict> {
                    var models = [CategoryModel]()
                    subcategories.forEach {
                        models.append(self.transform($0))
                    }
                    completion(models)
                }
            })
    }
    
    /// transform raw data into a CategoryModel
    private func transform(_ data: JSONDict) -> CategoryModel {
        guard let name = data["Name"] as? String,
            let number = data["Number"] as? String,
            let path = data["Path"] as? String,
            let isLeaf = data["IsLeaf"] as? Bool
            else {
                return CategoryModel(number: "", name: "", path: "")
        }
        return CategoryModel(number: number, name: name, path: path, isLeaf: isLeaf)
    }
    
    /// request data of listings with parameter category
    func requestSearchResults(in category: String, completion: @escaping ([ListingModel]) -> Void) {
        guard let url = URL(string: "https://api.tmsandbox.co.nz/v1/Search/General.json?category=\(category)") else { return }
        let queue = DispatchQueue(label: "com.search.trademe", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .get,
                          headers:[.authorizationKey: authValue])
            .responseJSON(queue: queue, completionHandler: { response in
                guard response.result.isSuccess else { return }
                guard let data = response.result.value as? JSONDict else { return }
                guard let count = data["TotalCount"] as? Int, count > 0 else { return }
                guard let list = data["List"] as? Array<JSONDict> else { return }
                
                var models = [ListingModel]()
                for index in 0..<min(count, 20) {
                    let model = self.transformList(list[index])
                    models.append(model)
                }
                completion(models)
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
        guard let name = json["Title"] as? String,
            let id = json["ListingId"] as? Int else { return ListingModel(name: "", id: 0, photoURL: nil) }
        let photoURL = json["PictureHref"] as? String
        let model = ListingModel(name: name, id: id, photoURL: photoURL)
        return model
    }
    
    /// Returns a Request just in case that sometimes we want to cancel the request
    @discardableResult
    func requestImage(_ url: String, completion: @escaping (UIImage) -> Void = { _ in }) -> Request? {
        guard let imageURL = URL(string: url) else { return nil }
        let request = Alamofire.request(url)
        let queue = DispatchQueue(label: "com.thumbnail.trademe", qos: .background, attributes: .concurrent)
        DispatchQueue.global().async {
            Alamofire.request(imageURL).responseImage(queue: queue) { response in
                guard let image = response.result.value else { return }
                self.cachedImages.add(image, withIdentifier: url)
                completion(image)
            }
        }
        
        return request
    }
    
    func cachedImage(_ url: String) -> Image? {
        return cachedImages.image(withIdentifier: url)
    }
}
