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
    var filterString: String?
    
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

        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonTapped))
        }
    }
    @objc func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchListings() {
        guard let categoryNumber = parentCategory?.number else { return }
        ModelManager.shared.requestSearchResults(in: categoryNumber, filter: filterString, completion: {
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
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
            if listing.modelState.didSet == nil {
                listing.modelState.didSet = {
                    state in
                    guard state.value == .ready else {
                        return
                    }
                    DispatchQueue.main.async {
                        guard let updatedCell = collectionView.cellForItem(at: indexPath) as? ListDetailCell else {
                            // the cell at indexPath is not visible
                            return
                        }
                        updatedCell.stopLoadingAnimation()
                        updatedCell.thumbnail.image = listing.photo
                    }
                }
            }
            switch listing.modelState.value {
            case .needsUpdate:
                cell.thumbnail.image = nil
                cell.startLoadingAnimation()
                listing.fetchPhotoIfNecessary()
            case .ready:
                cell.stopLoadingAnimation()
                cell.thumbnail.image = listing.photo
            case .updateInProgress:
                cell.thumbnail.image = nil
                cell.startLoadingAnimation()
            }

            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let listing = listings[indexPath.item]
        guard let detailCell = cell as? ListDetailCell else { return }
        switch listing.modelState.value {
        case .ready:
            detailCell.stopLoadingAnimation()
            detailCell.thumbnail.image = listing.photo
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let listing = listings[indexPath.item]
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        nextVC.listingID = listing.id
        nextVC.photoHref = listing.photoURL
        navigationController?.pushViewController(nextVC, animated: true)
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
