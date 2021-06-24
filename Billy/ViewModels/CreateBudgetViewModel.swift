//
//  CreateBudgetViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 18/12/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class CreateBudgetViewModel: ObservableObject {
    @Published var title: String = ""
    
    lazy var titleValidation: ValidationPublisher = {
        $title.nonEmptyValidator("\(Strings.formTitle.toLocalizedString)\(Strings.mustNotBeEmpty.toLocalizedString)")
    }()
    
    lazy var allValidation: ValidationPublisher = {
        return titleValidation
        }()
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    @Binding var isShowing: Bool
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let budgetService: BudgetServiceProtocol
    
    var actionTypeText: String = Strings.newMale.toLocalizedString
    var buttonText: String = Strings.create.toLocalizedString
    
    enum Action {
        case create
    }
    
    init(isShowing: Binding<Bool>, userService: UserServiceProtocol = UserService(), budgetService: BudgetServiceProtocol = BudgetService()) {
        self.userService = userService
        self.budgetService = budgetService
        self._isShowing = isShowing
    }
    
    func send(action: Action) {
        switch action {
            case .create:
                isLoading = true
                currentUserId().flatMap { user -> AnyPublisher<Void, BillyError> in
                    return self.createBudget(user: user)
                }
                .sink { completion in
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            print("finished")
                            self.isShowing = false
                    }
                    self.isLoading = false
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func createBudget(user: User) -> AnyPublisher<Void, BillyError> {
        let id = UUID().uuidString
        let budget = Budget(
            title: title,
            userPermissions: [
                user.uid: UserPermission(email: user.email, permission: .edit)
            ],
            bankAccounts: [
                id: Account(
                    id: id,
                    type: .checking,
                    name: Strings.myAccount.toLocalizedString,
                    freeBalance: 0,
                    description: Strings.initialAccount.toLocalizedString,
                    frozenBalance: 0
                )
            ]
        )
        
        Analytics.logEvent("newBudget", parameters: nil)
        
        return budgetService.create(budget).eraseToAnyPublisher()
    }
        
    private func currentUserId() -> AnyPublisher<User, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<User, BillyError> in
            return Just(user!)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

