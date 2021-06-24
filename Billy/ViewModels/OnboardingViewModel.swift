//
//  OnboardingViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import Combine
import Firebase

final class OnboardingViewModel: ObservableObject {
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    @Published var isLoginPushed: Bool = false
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let budgetService: BudgetServiceProtocol
    
    let onboardingItems: [OnboardingItem] = [
        OnboardingItem(image: "wallet", title: Strings.onboardingOneTitle.toLocalizedString, description: Strings.onboardingOneBody.toLocalizedString),
        OnboardingItem(image: "goals", title: Strings.onboardingTwoTitle.toLocalizedString, description: Strings.onboardingTwoBody.toLocalizedString),
        OnboardingItem(image: "collab", title: Strings.onboardingThreeTitle.toLocalizedString, description: Strings.onboardingThreeBody.toLocalizedString)
    ]
    
    enum Action {
        case createFirstEmptyBudget
    }
    
    init(userService: UserServiceProtocol = UserService(), budgetService: BudgetServiceProtocol = BudgetService()) {
        self.userService = userService
        self.budgetService = budgetService
    }
    
    func send(action: Action) {
        switch action {
            case .createFirstEmptyBudget:
                isLoading = true
                currentUserId().flatMap { user -> AnyPublisher<Void, BillyError> in
                    return self.createBudget(user: user)
                }
                .sink { completion in
                    self.isLoading = false
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            print("finished")
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func createBudget(user: User) -> AnyPublisher<Void, BillyError> {
        let id = UUID().uuidString
        let budget = Budget(
            title: Strings.initialBudget.toLocalizedString,
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
        
        return budgetService.create(budget).eraseToAnyPublisher()
    }
    
    private func currentUserId() -> AnyPublisher<User, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<User, BillyError> in
            if let user = user {
                return Just(user)
                    .setFailureType(to: BillyError.self)
                    .eraseToAnyPublisher()
            } else {
                return self.userService
                    .signInAnonymously()
                    .map { $0 }
                    .eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}
