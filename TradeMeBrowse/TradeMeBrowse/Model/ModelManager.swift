//
//  ModelManager.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Alamofire

typealias JSONDict = Dictionary<String, Any>

class ModelManager: NSObject {

    static var shared = ModelManager()
    
    func requestCategory(_ number: String, depth: UInt = 1, completion: @escaping ([CategoryModel]) -> Void) {
        guard let url = URL(string: "https://api.tmsandbox.co.nz/v1/Categories/\(number).json?depth=\(depth)") else { return }
        
        Alamofire.request(url, method: .get)
            .responseJSON(completionHandler: { response in
                guard response.result.isSuccess else { return }
                guard let data = response.result.value as? JSONDict else { return }
                print("result value \(data)")
                if let subcategories = data["Subcategories"] as? Array<JSONDict> {
                    var models = [CategoryModel]()
                    subcategories.forEach({
                        models.append(self.transform($0))
                    })
                    completion(models)
                }
            })
    }
    
    private func transform(_ data: Dictionary<String, Any>) -> CategoryModel {
        guard let name = data["Name"] as? String,
            let number = data["Number"] as? String,
            let path = data["Path"] as? String,
            let isLeaf = data["IsLeaf"] as? Bool
            else {
                return CategoryModel(number: "", name: "", path: "")
        }
        return CategoryModel(number: number, name: name, path: path, isLeaf: isLeaf)
    }
}
