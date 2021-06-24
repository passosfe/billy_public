//
//  AccountsViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 22/12/20.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

final class AccountsViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let accountService: BankAccountServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published private(set) var accountItemsViewModels: [AccountItemViewModel] = []
    @Published var minimumAccountError: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var showingActionSheet = false
    @Published private(set) var error: BillyError?
    
    var checkingUserPremiumStatus = false
    let budgetId: String
    
    var totalFreeBalance: Double {
        accountItemsViewModels.reduce(0) { $0 + Double($1.account.freeBalance) / 100 }
    }
    var totalFrozenBalance: Double {
        accountItemsViewModels.reduce(0) { $0 + Double($1.account.frozenBalance ?? 0) / 100 }
    }
    var totalBalanceNumber: Double {
        totalFreeBalance + totalFrozenBalance
    }
    var freeBalancePercentage: Double {
        totalFreeBalance / totalBalanceNumber
    }
    var frozenBalancePercentage: Double {
        totalFrozenBalance / totalBalanceNumber
    }
    var totalBalance: String {
        NumberFormatter.currencyFormatter.string(for: totalBalanceNumber)!
    }
    var totalBalanceLabelFont: Font {
        let total = abs(totalBalanceNumber)
        if total > 100000 {
            return .body
        } else if total > 10000 {
            return .title3
        } else {
            return .title2
        }
    }
    
    enum Action {
        case delete
        case create
    }
    
    var userSettings: UserSettings
    
    init(userSettings: UserSettings, budgets: [Budget], userService: UserServiceProtocol = UserService(), accountService: BankAccountServiceProtocol = BankAccountService(), purchaseService: PurchaseServiceProtocol = PurchaseService()) {
        self.userService = userService
        self.accountService = accountService
        self.purchaseService = purchaseService
        self.userSettings = userSettings
        var budget: Budget
        if let mainBudgetId = self.userSettings.mainBudgetId {
            budget = budgets.first { $0.id == mainBudgetId } ?? budgets[0]
        } else {
            self.userSettings.mainBudgetId =  budgets[0].id
            budget = budgets[0]
        }
        self.budgetId = budget.id!
        self.accountItemsViewModels = budget.bankAccounts?.map { AccountItemViewModel(account: $1) } ?? []
    }
    
    func send(action: Action, itemViewModel: AccountItemViewModel? = nil) {
        switch action {
        case .create:
            showingActionSheet = true
        case .delete:
            if accountItemsViewModels.count <= 1 {
                minimumAccountError = true
            } else {
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    guard let id = itemViewModel?.id else { return Fail(error: .default()).eraseToAnyPublisher()  }
                    return self.accountService.delete(id, budgetId: self.budgetId)
                }
                .sink { completion in
                    switch completion {
                        case let .failure(error):
                            print(error)
                        case .finished:
                            print("success")
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
            }
        }
    }
    
    func insideLimit(for key: ValueKey, value: Int, ifInside: @escaping () -> Void, ifOutside: @escaping () -> Void) {
        if !checkingUserPremiumStatus {
            self.checkingUserPremiumStatus = true
            let remoteValue = RCValues.sharedInstance.ammount(for: key)
            
            self.purchaseService.isPremiumUser().sink { [weak self] completion in
                guard let self = self else { return }
                self.checkingUserPremiumStatus = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { isPremiumUser in
                self.checkingUserPremiumStatus = false
                if isPremiumUser || remoteValue > value {
                    ifInside()
                } else {
                    ifOutside()
                }
            }.store(in: &self.cancellables)
        }
    }
    
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

final class AccountDetailViewModel: ObservableObject {
    @Published var account: Account
    
    enum Action {
        case edit
    }
    
    init(account: Account) {
        self.account = account
    }
    
    var totalFreeBalance: Double {
        Double(account.freeBalance) / 100
    }
    var totalFrozenBalance: Double {
        Double(account.frozenBalance!) / 100
    }
    var totalBalanceNumber: Double {
        totalFreeBalance + totalFrozenBalance
    }
    var freeBalancePercentage: Double {
        totalFreeBalance / totalBalanceNumber
    }
    var frozenBalancePercentage: Double {
        totalFrozenBalance / totalBalanceNumber
    }
    var totalBalance: String {
        NumberFormatter.currencyFormatter.string(for: totalBalanceNumber)!
    }
    
    var totalBalanceLabelFont: Font {
        let total = abs(totalBalanceNumber)
        if total > 100000 {
            return .body
        } else if total > 10000 {
            return .title3
        } else {
            return .title2
        }
    }
}

final class AccountItemViewModel: ObservableObject, Identifiable {
    @Published var account: Account
    @Published var offset: CGFloat = 0
    var id: String
    
    init(account: Account) {
        self.account = account
        self.id = account.id
    }
    
    var currentAmmount: Double {
        self.account.type == .creditCard ? (Double(self.account.limit! - self.account.freeBalance) / 100) : (Double(self.account.freeBalance + self.account.frozenBalance!) / 100)
    }
    
    var leftPercentage: Double {
        (Double(self.account.freeBalance) / 100) / currentAmmount
    }
    
    var rightPercentage: Double {
        (Double(self.account.frozenBalance!) / 100) / currentAmmount
    }
}
