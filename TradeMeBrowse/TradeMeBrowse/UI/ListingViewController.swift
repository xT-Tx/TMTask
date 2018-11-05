//
//  ListingViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/4.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController {

    var parentCategory: CategoryModel?
    
    var listings = [ListingModel]()
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = parentCategory?.name
        collectionView.register(UINib(nibName: "ListDetailCell", bundle: nil), forCellWithReuseIdentifier: "ListDetailCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchListings()
    }
    
    func fetchListings() {
        guard let categoryNumber = parentCategory?.number else { return }
        ModelManager.shared.requestSearchResults(in: categoryNumber, completion: {
            result in
            switch result {
            case .success(let models):
                self.listings = models
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
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

extension ListingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ListDetailCell", for: indexPath) as? ListDetailCell {
            let listing = listings[indexPath.item]
            cell.title.text = listing.name
            cell.ListingID.text = "\(listing.id)"
            cell.startLoadingAnimation()
            listing.fetchPhotoIfNecessary { (image) in
                DispatchQueue.main.async {
                    cell.thumbnail.image = image
                    cell.stopLoadingAnimation()
                }
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ListingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 72)
    }
}

import Alamofire
extension UIAlertController {
    class func createAlert(for error: ModelError) -> UIAlertController {
        let message = error == .emptyData ? "No data in this category." : "Failed to request data."
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
