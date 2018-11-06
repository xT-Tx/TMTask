//
//  ModelManagerTests.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/6.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import XCTest
@testable import TradeMeBrowse

class ModelManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTransformItemDetails() {
        let json: JSONDict = ["ListingId": 6905863,
                              "Title": "Toyota Highlander Limited 4WD 7 seater 2014",
                              "Category": "0001-0268-0334-",
                              "BuyNowPrice": 35810,
            "Region": "Auckland",
            "PhotoId": 4347905
        ]
        let model = ModelManager.transform()
    }

}
