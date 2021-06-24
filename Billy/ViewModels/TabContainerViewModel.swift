//
//  TabContainerViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 09/11/20.
//

import Foundation
import Combine
import Firebase

final class TabContainerViewModel: ObservableObject {
    @Published var selectedTab = TabItemViewModel.TabItemType.home
    @Published var budgets: [Budget] = [Budget(id: "placeholder", title: "", userPermissions: [:], categoriesLimits: nil, spendingHistory: nil, bankAccounts: nil)]
    
    private let userService: UserServiceProtocol
    private let budgetService: BudgetServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published private(set) var error: BillyError?
    @Published private(set) var isLoading: Bool = false
    
    var userSettings: UserSettings
    
    init(userSettings: UserSettings, budgetService: BudgetServiceProtocol = BudgetService(), userService: UserServiceProtocol = UserService()) {
        self.userSettings = userSettings
        self.userService = userService
        self.budgetService = budgetService
        self.observeBudget()
    }
    
    let tabItemViewModels = [
        TabItemViewModel(imageName: "house", title: Strings.home.toLocalizedString, type: .home),
        .init(imageName: "building.columns", title: Strings.accounts.toLocalizedString, type: .accounts),
        .init(imageName: "target", title: Strings.objectives.toLocalizedString, type: .objectives),
        .init(imageName: "person", title: Strings.profile.toLocalizedString, type: .profile)
    ]
    
    private func observeBudget() {
        isLoading = true
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<[Budget], BillyError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.budgetService.observeBudgets(userId: userId)
            }.sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] budgets in
                guard let self = self else { return }
                self.error = nil
                if budgets.count > 0 {
                    self.budgets = budgets
                    self.isLoading = false
                }
            }.store(in: &cancellables)
    }
}

struct TabItemViewModel: Hashable {
    let imageName: String
    let title: String
    let type: TabItemType
    
    enum TabItemType {
        case home
        case accounts
        case objectives
        case profile
    }
}
