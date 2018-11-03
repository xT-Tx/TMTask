//
//  ViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://api.tmsandbox.co.nz/v1/Categories/0.json") else { return }
        
        Alamofire.request(url, method: .get)
        .responseJSON(completionHandler: { response in
            guard response.result.isSuccess else { return }
            if let data = response.result.value {
                print("result value \(data)")
            }
        })
        
        guard let authUrl = URL(string: "https://api.tmsandbox.co.nz/v1/Search/General.json?category=3720") else { return }
        Alamofire.request(authUrl, method: .get,
                          headers: ["Authorization": "OAuth oauth_consumer_key=\"A1AC63F0332A131A78FAC304D007E7D1\",oauth_token=\"206ED521E5552AB32EF768A2B1CCB64C\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"1541215495\",oauth_nonce=\"2rQiz7\",oauth_version=\"1.0\",oauth_signature=\"EC7F18B17A062962C6930A8AE88B16C7%261EB57D8A2A05AF0795F0FC17DD58C187\""])
            .responseJSON(completionHandler: { response in
                guard response.result.isSuccess else { return }
                let des = response.result.description
                print("result value \(des)")
            })
    }
}

