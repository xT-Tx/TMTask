//
//  HomeViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    
    static fileprivate let cellIdentifier = "CategoryCell"

    fileprivate let categoryStore = CategoryStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All Categories"
        collectionView.register(UINib(nibName: HomeViewController.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: HomeViewController.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = ContentLayout()
        let state = categoryStore.updateCategory(completion: {[weak self]
            _, _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }, errorHandler: { [weak self]
            error in
                DispatchQueue.main.async {
                    if let modelError = error as? ModelError {
                        let alert = UIAlertController.createAlert(for: modelError)
                        self?.present(alert, animated: true, completion: nil)
                    }
                    self?.activityIndicator.stopAnimating()
                }
        })
        if state != .ready {
            activityIndicator.startAnimating()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryStore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.cellIdentifier, for: indexPath) as? CategoryCell {
            let category = categoryStore.category(at: indexPath.item)
            cell.name.text = category.name
            cell.level = category.level
            return cell
        }
        assert(true, "There must be something wrong!")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categoryStore.category(at: indexPath.item)
        if selectedCategory.isLeaf {
            let nextVCIdentifier = "ListingViewController"
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: nextVCIdentifier) as! ListingViewController
            nextVC.parentCategory = selectedCategory
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let navigationVC = UINavigationController(rootViewController: nextVC)
                navigationVC.modalPresentationStyle = .formSheet
                present(navigationVC, animated: true, completion: nil)
            }
            else {
                navigationController?.pushViewController(nextVC, animated: true)
            }
            return
        }
        
        // not a leaf node. drill down in this category
        let state = categoryStore.updateCategory(at: indexPath.item, completion: { [weak self]
            deleteItems, insertItems in
            DispatchQueue.main.async {
                self?.collectionView.performBatchUpdates({
                    if let layout = self?.collectionView.collectionViewLayout as? ContentLayout {
                        layout.collectionViewContentChanged()
                    }
                    
                    self?.collectionView.deleteItems(at: deleteItems)
                    self?.collectionView.insertItems(at: insertItems)
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.isUserInteractionEnabled = true
                }, completion: { _ in
                    guard let first = insertItems.first else { return }
                    self?.collectionView.scrollToItem(at: first, at: .centeredVertically, animated: true)
                })
            }
            }, errorHandler: { [weak self]
                error in
                DispatchQueue.main.async {
                    if let modelError = error as? ModelError {
                        let alert = UIAlertController.createAlert(for: modelError)
                        self?.present(alert, animated: true, completion: nil)
                    }
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.isUserInteractionEnabled = true
                }
        })
        if state != .ready {
            activityIndicator.startAnimating()
            collectionView.isUserInteractionEnabled = false
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: collectionView.bounds.size.width * (1 - 2*ContentLayout.marginPercent), height: 70)
        let level = CGFloat(categoryStore.category(at: indexPath.item).level)
        size.width = size.width - collectionView.bounds.size.width * ContentLayout.marginPercent * (level - 1)
        return size
    }
}
