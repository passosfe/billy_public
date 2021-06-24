//
//  CreateTransactionViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 25/11/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class CreateTransactionViewModel: ObservableObject {
    @Published var transactionType: TransactionType = .expense
    @Published var date: Date = Date()
    @Published var fromAccount: Account
    @Published var toAccount: Account?
    @Published var transactionAmmount: String = ""
    @Published var transactionDescription: String = ""
    @Published var category: StandardCategory? = .bills
    
    var transactionValue: Double {
        (Double(transactionAmmount) ?? 0.0) / 100
    }
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let transactionService: TransactionServiceProtocol
    
    let transactionTypes: [TransactionType] = TransactionType.allCases
    let categoryTypes: [StandardCategory] = StandardCategory.allCases
    
    private let budgetId: String
    let bankAccounts: [Account]
    @Binding var isShowing: Bool
    @Binding var isTransactionEdited: Bool?
    private var transactionDocId: String?
    
    var actionTypeText: String = Strings.new.toLocalizedString
    var buttonText: String = Strings.create.toLocalizedString
    
    enum Action {
        case saveTransaction
    }
    
    init(budgetId: String, bankAccounts: [Account], isShowing: Binding<Bool>, editTransaction: Transaction? = nil, isTransactionEdited: Binding<Bool?> = .constant(nil), userService: UserServiceProtocol = UserService(), transactionService: TransactionServiceProtocol = TransactionService()) {
        self.bankAccounts = bankAccounts
        if let transaction = editTransaction {
            self.actionTypeText = Strings.editAction.toLocalizedString
            self.buttonText = Strings.save.toLocalizedString
            self.transactionDocId = editTransaction?.docId ?? editTransaction?.id
            self.transactionType = transaction.type
            self.date = transaction.date
            self.fromAccount = self.bankAccounts.first { $0.id == transaction.fromAccount }!
            self.toAccount = self.bankAccounts.first { $0.id == transaction.toAccount }
            self.transactionAmmount = String(transaction.ammount)
            self.transactionDescription = transaction.description ?? ""
            self.category = transaction.category
        } else {
            self.fromAccount = self.bankAccounts[0]
        }
        self._isTransactionEdited = isTransactionEdited
        self._isShowing = isShowing
        self.budgetId = budgetId
        self.userService = userService
        self.transactionService = transactionService
    }
    
    func send(action: Action) {
        switch action {
            case .saveTransaction:
                isLoading = true
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    if let _ = self.transactionDocId {
                        return self.updateTransaction(userId: userId)
                    }
                    return self.createTransaction(userId: userId)
                }
                .sink { completion in
                    self.isLoading = false
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            if let _ = self.isTransactionEdited {
                                self.isTransactionEdited! = true
                            }
                            self.isShowing = false
                            print("finished")
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func createTransaction(userId: UserId) -> AnyPublisher<Void, BillyError> {
        let transaction = Transaction(
            description: transactionDescription,
            type: transactionType,
            date: date,
            ammount: Int(transactionValue * 100),
            category: category,
            fromAccount: fromAccount.id,
            toAccount: toAccount?.id,
            docId: nil
        )
        
        Analytics.logEvent("newTransaction", parameters: nil)
        
        return transactionService.create(transaction, budgetId: budgetId).eraseToAnyPublisher()
    }
    
    private func updateTransaction(userId: UserId) -> AnyPublisher<Void, BillyError> {
        let transaction = Transaction(
            description: transactionDescription,
            type: transactionType,
            date: date,
            ammount: Int(transactionValue * 100),
            category: category,
            fromAccount: fromAccount.id,
            toAccount: toAccount?.id,
            docId: nil
        )
        
        return transactionService.updateTransaction(transaction, transactionDocId: transactionDocId!, budgetId: budgetId).eraseToAnyPublisher()
    }
        
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
