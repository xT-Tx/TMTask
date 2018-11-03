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
    }
}

