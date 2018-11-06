//
//  DetailsViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/6.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var photoHref: String?
    var listingID: Int!
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet var id: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var region: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var photoHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestModel()
        if photoHref == nil {
            photoHeightConstraint.constant = 0
        }
        activityIndicator.startAnimating()
    }
    
    func requestModel() {
        ModelManager.shared.requestItemDetails(String(listingID), completion: {
            result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self.id.text = String(model.listingId)
                    self.price.text = "\(model.priceDisplay)"
                    self.region.text = model.region ?? "N/A"
                    self.activityIndicator.stopAnimating()
                    model.fetchPhotoIfNecessary(){
                        result in
                        if case let .success(image) = result {
                            DispatchQueue.main.async {
                                self.photo.image = image
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if let modelError = error as? ModelError {
                        let alert = UIAlertController.createAlert(for: modelError)
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        })
    }
}
