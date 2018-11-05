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
    fileprivate var categories: [CategoryModel] = [CategoryModel]()
    fileprivate var selectedCellPath: IndexPath? // keep a reference of selected cell
    fileprivate var expandedCategoryLevel = 0 // we can see all main categoies by default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All Categories"
        collectionView.register(UINib(nibName: HomeViewController.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: HomeViewController.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = ContentLayout()
        activityIndicator.startAnimating()
        updateCategory()
    }
    
    fileprivate func updateCategory() {
        ModelManager.shared.requestCategory("0", rootLevel: 0, depth: 1, completion: {
            models in
            self.categories = models
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        })
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewController.cellIdentifier, for: indexPath) as? CategoryCell {
            let category = categories[indexPath.item]
            cell.name.text = category.name
            return cell
        }
        assert(true, "There must something wrong!")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        if selectedCategory.isLeaf {
            let nextVCIdentifier = "ListingViewController"
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: nextVCIdentifier) as! ListingViewController
            nextVC.parentCategory = selectedCategory
            navigationController?.pushViewController(nextVC, animated: true)
            return
        }
        
        if let sub = selectedCategory.subCategories, sub.count > 0 {
            performBatchUpdate(for: selectedCategory, at: indexPath)
        }
        else {
            activityIndicator.startAnimating()
            collectionView.isUserInteractionEnabled = false
            ModelManager.shared.requestCategory(selectedCategory.number, rootLevel: selectedCategory.level, depth: 1, completion: {
                models in
                selectedCategory.subCategories = models
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    collectionView.isUserInteractionEnabled = true
                    self.performBatchUpdate(for: selectedCategory, at: indexPath)
                }
            })
        }
    }
    
    private func performBatchUpdate(for selectedCategory: CategoryModel, at indexPath: IndexPath) {
        guard let sub = selectedCategory.subCategories, sub.count > 0 else { return }
        collectionView.performBatchUpdates({ [weak self] in
            guard let strongSelf = self else { return }
            var deleteItems = [IndexPath]()
            var insertItems = [IndexPath]()
            if selectedCategory.level <= expandedCategoryLevel {
                for index in (0...strongSelf.categories.count-1).reversed() {
                    if strongSelf.categories[index].level > selectedCategory.level {
                        strongSelf.categories.remove(at: index)
                        deleteItems.append(IndexPath(item: index, section: 0))
                    }
                }
                
                let firstDeletedItem = deleteItems.first?.item ?? Int.max
                let updatedIndex = firstDeletedItem < indexPath.item ? indexPath.item - deleteItems.count : indexPath.item
                if strongSelf.selectedCellPath != nil && updatedIndex != strongSelf.selectedCellPath!.item {
                    var index = updatedIndex + 1
                    for category in sub {
                        strongSelf.categories.insert(category, at: index)
                        insertItems.append(IndexPath(item: index, section: 0))
                        index += 1
                    }
                    strongSelf.selectedCellPath = IndexPath(item: updatedIndex, section: 0)
                }
                else {
                    strongSelf.selectedCellPath = nil
                }
            }
            else {
                var index = indexPath.item + 1
                for category in sub {
                    strongSelf.categories.insert(category, at: index)
                    index += 1
                }
                insertItems = Array(indexPath.item+1..<index).map { IndexPath(item: $0, section: 0) }
                strongSelf.selectedCellPath = indexPath
            }
            
            strongSelf.expandedCategoryLevel = (strongSelf.selectedCellPath == nil ? selectedCategory.level - 1 : selectedCategory.level)
            collectionView.deleteItems(at: deleteItems)
            collectionView.insertItems(at: insertItems)
            
            }, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero
        
        let level = categories[indexPath.item].level
        switch level {
        case 1:
            size = CGSize(width: 150, height: 110)
        case 2:
            size = CGSize(width: 110, height: 90)
        case 3:
            size = CGSize(width: 90, height: 60)
        default:
            size = CGSize(width: 70, height: 40)
        }
        if let path = selectedCellPath {
            if path.item == indexPath.item {
                let width = collectionView.bounds.size.width * (1 - 2 * ContentLayout.marginPercent)
                size.width = width
            }
        }
        return size
    }
}
