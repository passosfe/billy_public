//
//  ManageObjectiveAmmountViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import Foundation
import Combine
import SwiftUI

final class ManageObjectiveAmmountViewModel: ObservableObject {
    @Published var fromAccount: Account
    @Published var ammount: String = ""
    
    var ammountValue: Double {
        (Double(ammount) ?? 0.0) / 100
    }
    
    var maxAvailable: Double {
        availableAmmounts[fromAccount.id] ?? 0
    }
    
    lazy var ammountValidationAbove: ValidationPublisher = {
        $ammount.aboveValidation(0, errorMessage: "\(Strings.formValue.toLocalizedString)\(Strings.mustBeAboveOf.toLocalizedString)\(NumberFormatter.currencyFormatter.string(from: 0)!)")
    }()
    lazy var ammountValidationUnder: ValidationPublisher = {
        $ammount.underValidation(maxAvailable * 100, errorMessage: "\(Strings.formValue.toLocalizedString)\(Strings.mustBeUnderOf.toLocalizedString)\(NumberFormatter.currencyFormatter.string(from: 0)!)")
    }()
    
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest(
            ammountValidationAbove,
            ammountValidationUnder
            ).map { v1, v2 in
                return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
            }.eraseToAnyPublisher()
        }()
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let objectiveService: ObjectiveServiceProtocol
    
    let bankAccounts: [Account]
    var availableAmmounts: [String: Double]
    private let budgetId: String
    private let objective: Objective
    private var isAdd: Bool = true
    @Binding var isShowing: Bool
    
    var actionTypeText: String = Strings.addMoney.toLocalizedString
    var buttonText: String = Strings.addMoney.toLocalizedString
    
    enum Action {
        case insertTransaction
    }
    
    init(budgetId: String, objective: Objective, accounts: [Account], isShowing: Binding<Bool>, transactionsHistory: [String: [AmmountsHistory]]? = nil, userService: UserServiceProtocol = UserService(), objectiveService: ObjectiveServiceProtocol = ObjectiveService()) {
        var accountsToShow: [Account] = accounts
        var availableAmmounts: [String: Double] = [:]
        if let transactionHistory = transactionsHistory {
            self.actionTypeText = Strings.withdraw.toLocalizedString
            self.buttonText = Strings.withdraw.toLocalizedString
            self.isAdd = false
            accountsToShow = accounts.filter { account in
                let ammount = transactionHistory[account.id]?.reduce(0) { $0 + $1.ammount }
                if let total = ammount, total > 0 {
                    availableAmmounts[account.id] = Double(total) / 100
                    return true
                }
                return false
            }
        } else {
            let _ = accounts.map { account in
                if account.freeBalance > 0 {
                    availableAmmounts[account.id] = Double(account.freeBalance) / 100
                }
            }
        }
        self.bankAccounts = accountsToShow
        self.fromAccount = accountsToShow[0]
        self.availableAmmounts = availableAmmounts
        self._isShowing = isShowing
        self.budgetId = budgetId
        self.objective = objective
        self.userService = userService
        self.objectiveService = objectiveService
    }
    
    func send(action: Action) {
        switch action {
            case .insertTransaction:
                isLoading = true
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    return self.insertObjectiveTransaction()
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
    
    private func insertObjectiveTransaction() -> AnyPublisher<Void, BillyError> {
        let transaction = AmmountsHistory(
            id: UUID().uuidString,
            accountId: fromAccount.id,
            date: Date(),
            ammount: Int((isAdd ? ammountValue : -ammountValue) * 100)
        )
        
        return objectiveService.insertTransaction(transaction, objective: objective, budgetId: budgetId).eraseToAnyPublisher()
        
    }
        
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
