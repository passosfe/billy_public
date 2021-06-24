//
//  CategoryItemViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 09/11/20.
//

import Foundation

final class CategoriesListViewModel: ObservableObject {
    @Published var itemViewModels: [CategoryItemViewModel] = []
    
    private let budgetId: String
    private let isInfiniteScroll: Bool
    
    @Published var showingEdit = false
    @Published var categoryToEdit: CategoryLimit?
    
    enum Action {
        case editLimit
    }
    
    init (categories: [CategoryLimit], budgetId: String = "", isInfiniteScroll: Bool = false) {
        self.budgetId = budgetId
        self.isInfiniteScroll = isInfiniteScroll
        self.itemViewModels =  categories.map { category in
            .init(category)
        }
    }
    
    func send(action: Action, itemViewModel: CategoryItemViewModel? = nil) {
        switch action {
        case .editLimit:
            if let category = itemViewModel?.category {
                self.categoryToEdit = category
                self.showingEdit = true
            }
        }
    }
}


final class CategoryItemViewModel: Identifiable, ObservableObject {
    @Published
    var category: CategoryLimit
    var progressCircleViewModel: ProgressCircleViewModel {
        let percentageSpent = (Double(category.currentSpent ?? 0) / 100) / (Double(category.maxAvailable) / 100)
        return .init(percentageSpent: percentageSpent, icon: icon())
    }
    
    var id: String {
        category.id
    }
    
    init(_ category: CategoryLimit) {
        self.category = category
    }
    
    func title() -> String {
        switch category.type {
        case .standard:
            return StandardCategory.init(rawValue: category.key)?.toLocalizedString ?? ""
        }
    }
    
    func icon() -> String {
        switch category.type {
        case .standard:
            return StandardCategory.init(rawValue: category.key)?.icon ?? ""
        }
    }
}
