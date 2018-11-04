//
//  ListingViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/4.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ListingViewController: UIViewController, CategoryPresenter {

    var parentCategory: CategoryModel?
    
    var listings = [ListingModel]()
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
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
            models in
            self.listings = models
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
