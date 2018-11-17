//
//  CategoryModel.swift
//  TradeMeBrowse
//
//  Created by JiangNan on 2018/11/3.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import Foundation

struct CategoryModel {
    let number: String
    let name: String
    let path: String
    let isLeaf: Bool
    
    var level = 0
    var subCategories: Array<CategoryModel>?
    
    init(number: String, name: String, path: String, isLeaf: Bool = false) {
        self.number = number
        self.name = name
        self.path = path
        self.isLeaf = isLeaf
    }
}

enum ModelState {
    case ready
    case needsUpdate
    case updateInProgress
}

class CategoryStore {

    private var categories: [CategoryModel] = []
    private var expandedCategoryLevel = 0 // we can see all main categoies by default
    private var expandedCategoryStack = [CategoryModel]()
    
    func category(at index: Int) -> CategoryModel {
        return categories[index]
    }
    
    var count: Int {
        return categories.count
    }
    
    func updateCategory(at index: Int = -1, completion: @escaping (_ deletedItems: [IndexPath], _ insertedItems: [IndexPath]) -> Void, errorHandler: @escaping (_ error: Error) -> Void) -> ModelState {
        if index == -1 {
            guard categories.count == 0 else { return .ready }
            ModelManager.shared.requestCategory("0", rootLevel: 0, depth: 1, completion: {
                result in
                switch result {
                case .success(let models):
                    self.categories = models
                    var insertItems = [IndexPath]()
                    for index in 0..<models.count {
                        insertItems.append(.init(item: index, section: 0))
                    }
                    completion([], insertItems)
                case .failure(let error):
                    errorHandler(error)
                    break
                }
            })
            return .updateInProgress
        }
        else {
            guard categories.count > 0 else { return .needsUpdate }
            let category = categories[index]
            if let count = category.subCategories?.count, count > 0 {
                expandCategory(at: index, completion: completion)
                return .ready
            }
            else {
                ModelManager.shared.requestCategory(category.number, rootLevel: category.level, depth: 1, completion: {
                    result in
                    switch result {
                    case .success(let models):
                        self.categories[index].subCategories = models
                        self.expandCategory(at: index, completion: completion)
                    case .failure(let error):
                        errorHandler(error)
                        break
                    }
                })
                return .updateInProgress
            }
        }
    }
    
    func expandCategory(at index: Int, completion: @escaping (_ deletedItems: [IndexPath], _ insertedItems: [IndexPath])->Void) {
        var deleteItems = [IndexPath]()
        var insertItems = [IndexPath]()
        
        var selectedCategory = categories[index]
        var updatedIndex = index
        guard let sub = selectedCategory.subCategories else  { return }
        if selectedCategory.level <= expandedCategoryLevel {
            // remove subcategories under the expanded category
            for index in (0...categories.count-1).reversed() {
                if categories[index].level > selectedCategory.level {
                    categories.remove(at: index)
                    deleteItems.append(IndexPath(item: index, section: 0))
                }
            }
            
            let firstDeletedItem = deleteItems.first?.item ?? Int.max
            updatedIndex = firstDeletedItem < index ? index - deleteItems.count : index
            selectedCategory = categories[updatedIndex]
            if expandedCategoryStack.contains(where: { $0.name == selectedCategory.name && $0.number == selectedCategory.number }) {
                // collpase the originally expanded category
                expandedCategoryStack = expandedCategoryStack.filter {
                    return $0.level < selectedCategory.level
                }
            }
            else {
                // expand another category
                var i = updatedIndex + 1
                for category in sub {
                    categories.insert(category, at: i)
                    insertItems.append(IndexPath(item: i, section: 0))
                    i += 1
                }
                expandedCategoryStack = expandedCategoryStack.filter {
                    return $0.level < selectedCategory.level
                }
                expandedCategoryStack.append(selectedCategory)
            }
        }
        else {
            var i = index + 1
            for category in sub {
                categories.insert(category, at: i)
                insertItems.append(IndexPath(item: i, section: 0))
                i += 1
            }
            expandedCategoryStack.append(selectedCategory)
        }

        if let lastExpandedCategory = expandedCategoryStack.last {
            expandedCategoryLevel = lastExpandedCategory.level
        }
        else {
            expandedCategoryLevel = 0
        }
        completion(deleteItems, insertItems)
    }
}
