//
//  ListingModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation
import Alamofire

class ListingModel {
    let name: String
    let id: Int
    var photoURL: String?
    var photo: UIImage? {
        guard let url = photoURL else {
            return nil
        }
        return ModelManager.shared.cachedImage(url)
    }

    var modelState: AtomicValue<ModelState> = AtomicValue(.needsUpdate)
    
    init(name: String, id: Int, photoURL: String?) {
        self.name = name
        self.id = id
        self.photoURL = photoURL
        if photoURL != nil {
            modelState.value = .needsUpdate
        }
        else {
            modelState.value = .ready
        }
    }
    
    func fetchPhotoIfNecessary() {
        guard let url = photoURL else {
            return
        }
        if let _ = ModelManager.shared.cachedImage(url) {
            modelState.value = .ready
        }
        else {
            guard modelState.value != .updateInProgress else { return }
            modelState.value = .updateInProgress
            ModelManager.shared.requestImage(url, completion: {
                result in
                self.modelState.value = .ready
            })
        }
    }
}

class AtomicValue<T> {
    
    private let queue = DispatchQueue(label: "com.syncedValue.trademe", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)

    private var _value: T
    init(_ value: T) { _value = value }
    
    /// The value.
    var value: T {
        get {
            var res: T?
            queue.sync(execute: { [unowned self] in res = self._value })
            return res!
        }
        set {
            queue.sync(execute: { [unowned self] in self._value = newValue })
            guard let didSet = didSet else { return }
            didSet(self)
        }
    }
    
    var didSet: ((AtomicValue) -> Void)?
}
