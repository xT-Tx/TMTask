//
//  SubcategoryViewController.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

protocol CategoryPresenter where Self: UIViewController {
    var parentCategory: CategoryModel? { get set }
}

class SubcategoryViewController: UIViewController, CategoryPresenter {

    var parentCategory: CategoryModel?
    
    @IBOutlet private var collectionView: UICollectionView!
    fileprivate static let cellIdentifier = "CategoryCell"
    fileprivate var categories: [CategoryModel] = [CategoryModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = parentCategory?.name
        collectionView.register(UINib(nibName: SubcategoryViewController.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: SubcategoryViewController.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = ContentLayout()
        updateCategory()
    }
    
    fileprivate func updateCategory() {
        guard let categoryNumber = parentCategory?.number else { return }
        ModelManager.shared.requestCategory(categoryNumber, completion: {
            models in
            self.categories = models
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
}

extension SubcategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SubcategoryViewController.cellIdentifier, for: indexPath) as? CategoryCell {
            let category = categories[indexPath.item]
            cell.name.text = category.name
            return cell
        }
        
        assert(true, "There must something wrong!")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        let nextVCIdentifier: String = category.isLeaf ? "ListingViewController" : "SubcategoryViewController"
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: nextVCIdentifier)
        if var categoryPresenter = nextVC as? CategoryPresenter {
            categoryPresenter.parentCategory = category
        }
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension SubcategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 110)
    }
}

