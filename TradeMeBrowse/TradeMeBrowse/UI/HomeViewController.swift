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
    
    static fileprivate let cellIdentifier = "CategoryCell"
    fileprivate var categories: [CategoryModel] = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All Categories"
        collectionView.register(UINib(nibName: HomeViewController.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: HomeViewController.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = ContentLayout()
        updateCategory()
    }
    
    fileprivate func updateCategory() {
        ModelManager.shared.requestCategory("0", completion: { [weak self]
            models in
            if let strongSelf = self {
                strongSelf.categories = models
                strongSelf.collectionView.reloadData()
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
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let subVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubcategoryViewController") as? SubcategoryViewController else { return }
        subVC.parentCategory = categories[indexPath.item]
        navigationController?.pushViewController(subVC, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 110)
    }
}
