//
//  CreateCategoryLimitViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 09/12/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class CreateCategoryLimitViewModel: ObservableObject {
    @Published var maxMonthlyAvailable: String = ""
    @Published var category: StandardCategory? = .bills
    
    var maxMonthlyAvailableValue: Double {
        (Double(maxMonthlyAvailable) ?? 0.0) / 100
    }
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let categoryLimitService: CategoryLimitServiceProtocol
    
    var categoryTypes: [StandardCategory]
    
    private let budgetId: String
    @Binding var isShowing: Bool
    private var categoryLimitId: String?
    
    var actionTypeText: String = Strings.newMale.toLocalizedString
    var buttonText: String = Strings.create.toLocalizedString
    let otherCategoryProperties: CategoryLimit?
    
    enum Action {
        case saveCategoryLimit
    }
    
    init(budgetId: String, availableCategories: [StandardCategory], isShowing: Binding<Bool>, editCategoryLimit: CategoryLimit? = nil, userService: UserServiceProtocol = UserService(), categoryLimitService: CategoryLimitServiceProtocol = CategoryLimitService()) {
        self.categoryTypes = availableCategories
        if let categoryLimit = editCategoryLimit {
            self.actionTypeText = Strings.editAction.toLocalizedString
            self.buttonText = Strings.save.toLocalizedString
            self.categoryLimitId = categoryLimit.id
            self.maxMonthlyAvailable = String(categoryLimit.maxAvailable)
            self.category = StandardCategory(rawValue: categoryLimit.key)
            self.categoryTypes.append(StandardCategory(rawValue: categoryLimit.key)!)
        } else {
            self.category = availableCategories.first
        }
        self.otherCategoryProperties = editCategoryLimit
        self._isShowing = isShowing
        self.budgetId = budgetId
        self.userService = userService
        self.categoryLimitService = categoryLimitService
    }
    
    func send(action: Action) {
        switch action {
            case .saveCategoryLimit:
                isLoading = true
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    return self.upInsertcategoryLimit(userId: userId)
                }
                .sink { completion in
                    self.isLoading = false
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            self.isShowing = false
                            print("finished")
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func upInsertcategoryLimit(userId: UserId) -> AnyPublisher<Void, BillyError> {
        var categoryLimit: CategoryLimit
        
        if let cat = otherCategoryProperties {
            categoryLimit = CategoryLimit(
                id: cat.id,
                key: category!.rawValue,
                type: .standard,
                currentSpent: nil,
                maxAvailable: Int(maxMonthlyAvailableValue * 100),
                lastTransactionAt: cat.lastTransactionAt
            )
        } else {
            categoryLimit = CategoryLimit(
                id: UUID().uuidString,
                key: category!.rawValue,
                type: .standard,
                currentSpent: nil,
                maxAvailable: Int(maxMonthlyAvailableValue * 100),
                lastTransactionAt: nil
            )
            
            Analytics.logEvent("newCategoryLimit", parameters: nil)
        }
        
        return categoryLimitService.create(categoryLimit, budgetId: budgetId).eraseToAnyPublisher()
    }
        
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
