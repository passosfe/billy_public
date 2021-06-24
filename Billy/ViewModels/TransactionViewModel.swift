//
//  TransactionItemViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

final class TransactionListViewModel: ObservableObject {
    @Published var itemViewModels: [TransactionItemViewModel] = []
    @Published var date: Date = Date()
    var dateLabel: String {
        date.getFormattedDate(format: Date().year == date.year ? "MMMM" : "MMM yyyy")
    }
    
    @Published var error: BillyError?
    @Published private(set) var isLoading: Bool = false
    @Published var showingEdit = false {
        willSet {
            if newValue == false, showingEdit == true, let isEdited = isTransactionEdited, isEdited {
                isTransactionEdited! = false
                lastDoc = nil
                lastReached = false
                itemViewModels = []
                getTransactions(clearTransactions: true)
            }
        }
    }
    @Published var isTransactionEdited: Bool? = false
    @Published private(set) var bankAccounts: [Account]?
    @Published var transactionToEdit: Transaction?
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let transactionService: TransactionServiceProtocol
    
    enum Action {
        case deleteTransaction
        case editTransaction
        case loadMore
        case nextMonth
        case prevMonth
    }
    
    private let budgetId: String
    private let isInfiniteScroll: Bool
    private var lastDoc: DocumentSnapshot?
    private var filterAccountId: String?
    private var lastReached: Bool = false
    private let loadAmmount = 10
    
    init (budgetId: String, bankAccounts: [Account]? = nil, isInfiniteScroll: Bool = false, transactions: [Transaction]? = nil, filterAccountId: String? = nil, userService: UserServiceProtocol = UserService(), transactionService: TransactionServiceProtocol = TransactionService()) {
        self.budgetId = budgetId
        self.userService = userService
        self.transactionService = transactionService
        self.isInfiniteScroll = isInfiniteScroll
        self.bankAccounts = bankAccounts
        self.filterAccountId = filterAccountId
        if let transactionList = transactions {
            self.itemViewModels =  transactionList.map { transaction in
                .init(transaction)
            }
        } else {
            getTransactions()
        }
    }
    
    func send(action: Action, transactionViewModel: TransactionItemViewModel? = nil) {
        switch action {
            case .deleteTransaction:
                // FIXME: delete quando é lastdoc
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    guard let id = transactionViewModel?.id else { return Fail(error: .default()).eraseToAnyPublisher()  }
                    return self.transactionService.delete(id, budgetId: self.budgetId)
                }
                .sink { completion in
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            let indexToRemove = self.itemViewModels.firstIndex { $0.id == transactionViewModel!.id }
                            if let index = indexToRemove {
                                self.itemViewModels.remove(at: index)
                            }
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        case .editTransaction:
            if let transaction = transactionViewModel?.transaction {
                self.transactionToEdit = transaction
                self.showingEdit = true
            }
        case .loadMore:
            if isInfiniteScroll, let lastId = transactionViewModel?.id, self.isLastTransaction(lastId), !self.lastReached {
                getTransactions()
            }
        case .nextMonth:
            if self.date.endOfMonth != Date().endOfMonth {
                self.date = self.date.nextMonthDate
                self.lastDoc = nil
                self.lastReached = false
                self.itemViewModels = []
                getTransactions(clearTransactions: true)
            }
        case .prevMonth:
            self.date = self.date.previousMonthDate
            self.lastDoc = nil
            self.lastReached = false
            self.itemViewModels = []
            getTransactions(clearTransactions: true)
        }
    }
    
    private func getTransactions(clearTransactions: Bool = false) {
        if self.lastReached {
            return
        }
        
        isLoading = true
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, transactions: [Transaction]), BillyError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.transactionService.getTransactions(date: self.date, budgetId: self.budgetId, limit: self.loadAmmount, lastDoc: self.lastDoc, filterAccountId: self.filterAccountId)
            }.sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] transactionsInfo in
                guard let self = self else { return }
                self.error = nil
                self.isLoading = false
                if self.lastDoc == transactionsInfo.lastDoc || transactionsInfo.lastDoc == nil {
                    self.lastReached = true
                } else {
                    self.lastDoc = transactionsInfo.lastDoc
                    let newTransactions: [TransactionItemViewModel] = transactionsInfo.transactions.map { transaction in
                        .init(transaction)
                    }
                    if !clearTransactions {
                        self.itemViewModels.append(contentsOf: newTransactions)
                    } else {
                        self.itemViewModels = newTransactions
                    }
                }
            }.store(in: &cancellables)
    }
    
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    private func isLastTransaction(_ transactionId: String) -> Bool {
        if let lastId = self.itemViewModels.last?.id {
            return lastId == transactionId
        }
        return false
    }
}

final class TransactionItemViewModel: Identifiable, ObservableObject {
    @Published var transaction: Transaction
    @Published var offset: CGFloat = 0
    
    var id: String {
        transaction.docId ?? transaction.id ?? ""
    }
    
    var title: String {
        transaction.description!.count > 0 ? transaction.description! : transaction.type.toLocalizedString
    }
    
    var subTitle: String {
        transaction.category?.toLocalizedString ?? transaction.type.toLocalizedString
    }
    
    var icon: String {
        transaction.category?.icon ?? "💸"
    }
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
    }
}
