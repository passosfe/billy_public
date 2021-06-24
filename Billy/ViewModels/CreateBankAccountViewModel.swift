//
//  CreateTransactionViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

typealias UserId = String

final class CreateBankAccountViewModel: ObservableObject {
    @Published var accountType: AccountType = .checking
    @Published var accountName: String = ""
    @Published var accountBalance: String = ""
    @Published var accountDescription: String = ""
    @Published var isNegativeBalance = false
    
    var accountBalanceValue: Double {
        (isNegativeBalance ? (Double(accountBalance) ?? 0.0) * -1 : (Double(accountBalance) ?? 0.0)) / 100
    }
    
    lazy var accountNameValidation: ValidationPublisher = {
        $accountName.nonEmptyValidator("\(Strings.accountName.toLocalizedString) \(Strings.mustNotBeEmpty.toLocalizedString)")
    }()
    
    lazy var allValidation: ValidationPublisher = {
        return accountNameValidation
    }()
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    @Binding var isShowing: Bool
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let bankAccountService: BankAccountServiceProtocol
    
    let accountTypes: [AccountType]
    private let budgetId: String
    
    enum Action {
        case createBankAccount
    }
    
    init(budgetId: String, isShowing: Binding<Bool>, userService: UserServiceProtocol = UserService(), bankAccountService: BankAccountServiceProtocol = BankAccountService()) {
        self.budgetId = budgetId
        self._isShowing = isShowing
        self.userService = userService
        self.bankAccountService = bankAccountService
        accountTypes = AccountType.allCases.filter { $0 != .creditCard }
    }
    
    func send(action: Action) {
        switch action {
            case .createBankAccount:
                isLoading = true
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    return self.createBankAccount(userId: userId)
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
    
    private func createBankAccount(userId: UserId) -> AnyPublisher<Void, BillyError> {
        let bankAccount = Account(
            id: UUID().uuidString,
            type: accountType,
            name: accountName,
            freeBalance: Int(accountBalanceValue * 100),
            description: accountDescription,
            frozenBalance: 0
        )
        
        Analytics.logEvent("newBankAccount", parameters: nil)
        
        return bankAccountService.create(bankAccount, budgetId: budgetId).eraseToAnyPublisher()
    }
        
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
