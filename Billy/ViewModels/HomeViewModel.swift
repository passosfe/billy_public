//
//  HomeViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation
import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let categoryService: CategoryLimitServiceProtocol
    private let transactionService: TransactionServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    let title = "Challenges"
    
    @Published private(set) var categoriesListViewModel: CategoriesListViewModel = CategoriesListViewModel(categories: [])
    @Published private(set) var transactionListViewModel: TransactionListViewModel = TransactionListViewModel(budgetId: "", bankAccounts: [], transactions: [])
    @Published private(set) var lineChartViewModel: [TabButton.TabButtonTitle: LineChartViewModel] = [.week: LineChartViewModel(), .month: LineChartViewModel(), .year: LineChartViewModel()]
    @Published private(set) var error: BillyError?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var totals: [TabButton.TabButtonTitle: Double] = [.week: 0, .month: 0, .year: 0]
    @Published private(set) var bankAccounts: [Account]?
    @Published var showingActionSheet = false
    @Published private var categoriesLimits: [String: CategoryLimit]?
    
    var checkingUserPremiumStatus = false
    var availableCategories: [StandardCategory] {
        categoriesListViewModel.itemViewModels.map { StandardCategory(rawValue: $0.category.key)! }.difference(from: StandardCategory.allCases)
    }
    
    @ObservedObject var userSettings: UserSettings
    
    init(userSettings: UserSettings, budgets: [Budget], userService: UserServiceProtocol = UserService(), categoryService: CategoryLimitServiceProtocol = CategoryLimitService(), transactionService: TransactionServiceProtocol = TransactionService(), purchaseService: PurchaseServiceProtocol = PurchaseService()) {
        self.userSettings = userSettings
        self.userService = userService
        self.purchaseService = purchaseService
        self.transactionService = transactionService
        self.categoryService = categoryService
        var budget: Budget
        if let mainBudgetId = self.userSettings.mainBudgetId {
            budget = budgets.first { $0.id == mainBudgetId } ?? budgets[0]
        } else {
            self.userSettings.mainBudgetId =  budgets[0].id
            budget = budgets[0]
        }
        self.categoriesLimits = budget.categoriesLimits
        self.bankAccounts = budget.bankAccounts?.map { $1 }
        self.lineChartViewModel = self.calculateSpendings(budget.spendingHistory)
        self.observeCategoryTransactions(budgetId: budget.id!)
        self.observeTransactions(budgetId: budget.id!)
    }

    enum Action {
        case create
   }
    
    func send(action: Action) {
        switch action {
        case .create:
            showingActionSheet = true
        }
    }
    
    private func observeCategoryTransactions(budgetId: String) {
        isLoading = true
        categoryService.observeCategoriesTransactions(budgetId: budgetId)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] categoryTransactions in
                guard let self = self else { return }
                self.error = nil
                if let categories = self.categoriesLimits {
                    self.categoriesListViewModel = .init(categories: categories.map { id, category in
                        if let currentSpent = categoryTransactions.categoryTransactions[category.key] {
                            return CategoryLimit(
                                id: category.id,
                                key: category.key,
                                type: category.type,
                                currentSpent: currentSpent,
                                maxAvailable: category.maxAvailable,
                                lastTransactionAt: category.lastTransactionAt)
                        }
                        return category
                    } .sorted(by: { categoryOne, categoryTwo in
                        if let categoryOneLastTransaction = categoryOne.lastTransactionAt {
                            if let categoryTwoLastTransaction = categoryTwo.lastTransactionAt {
                                return categoryOneLastTransaction > categoryTwoLastTransaction
                            }
                            return true;
                        }
                        return categoryOne.key > categoryTwo.key
                    }))
                }
                self.isLoading = false
            }.store(in: &cancellables)
    }
    
    private func observeTransactions(budgetId: String) {
        isLoading = true
        transactionService.observeTransactions(budgetId: budgetId, limit: 5)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] transactions in
                guard let self = self else { return }
                self.error = nil
                self.transactionListViewModel = .init(budgetId: budgetId, bankAccounts: self.bankAccounts, transactions: transactions)
                self.isLoading = false
            }.store(in: &cancellables)
    }
    
    private func calculateSpendings(_ values: [String: [String: [String: SpendingHistoryData]]]?) -> [TabButton.TabButtonTitle: LineChartViewModel] {
        if let values = values {
            var spendings: [TabButton.TabButtonTitle: LineChartViewModel] = [.week: LineChartViewModel(), .month: LineChartViewModel(), .year: LineChartViewModel()]
            
            if let yearSpendingsData = values["year"] {
                var totalYear: Double = 0
                var ammounts = Array(repeating: Double(0), count: 12)
                var labels = Array(repeating: "", count: 12)
                
                for yearData in yearSpendingsData.values {
                    let _ = yearData.mapValues { spending in
                        let index = abs(spending.date.startOfMonth.monthsFromNow)
                        if index >= 0, index < 12 {
                            totalYear += Double(spending.spendings) / 100
                            ammounts[index] += Double(spending.spendings) / 100
                            if labels[index] == "" {
                                labels[index] = spending.date.getFormattedDate(format: "MMMM yyyy")
                            }
                        }
                    }
                }
                totals[.year] = totalYear
                spendings[.year] = .init(ChartData(values: ammounts.reversed(), labels: labels.reversed()))
            }
            
            if let monthSpendingsData = values["month"] {
                var totalMonth: Double = 0
                var totalWeek: Double = 0
                var ammountsMonth = Array(repeating: Double(0), count: 30)
                var ammountsWeek = Array(repeating: Double(0), count: 7)
                var labelsMonth = Array(repeating: "", count: 30)
                var labelsWeek = Array(repeating: "", count: 7)
                
                for monthData in monthSpendingsData.values {
                    let _ = monthData.mapValues { spending in
                        let index = abs(spending.date.daysFromNow)
                        if index >= 0, index < 7 {
                            totalWeek += Double(spending.spendings) / 100
                            totalMonth += Double(spending.spendings) / 100
                            ammountsMonth[index] += Double(spending.spendings) / 100
                            ammountsWeek[index] += Double(spending.spendings) / 100
                            if labelsMonth[index] == "" {
                                labelsMonth[index] = spending.date.getFormattedDate(format: "MMM d")
                            }
                            if labelsWeek[index] == "" {
                                labelsWeek[index] = spending.date.getFormattedDate(format: "EEEE")
                            }
                        } else if index > 7, index < 30 {
                            totalMonth += Double(spending.spendings) / 100
                            ammountsMonth[index] += Double(spending.spendings) / 100
                            if labelsMonth[index] == "" {
                                labelsMonth[index] = spending.date.getFormattedDate(format: "MMM d")
                            }
                        }
                    }
                }
                totals[.week] = totalWeek
                totals[.month] = totalMonth
                spendings[.week] = .init(ChartData(values: ammountsWeek.reversed(), labels: labelsWeek.reversed()))
                spendings[.month] = .init(ChartData(values: ammountsMonth.reversed(), labels: labelsMonth.reversed()))
            }
            return spendings
        }
        return .init()
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
    
    func totalLimits(for period: TabButton.TabButtonTitle) -> Double {
        let totalLimit = categoriesListViewModel.itemViewModels.reduce(0) { $0 + $1.category.maxAvailable }
        
        switch period {
        case .week:
            return Double(totalLimit) / 400
        case .month:
            return Double(totalLimit) / 100
        case .year:
            return (Double(totalLimit) / 100) * 12
        }
    }
}
