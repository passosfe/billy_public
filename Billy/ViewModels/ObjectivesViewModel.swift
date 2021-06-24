//
//  ObjectivesViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

final class ObjectivesViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let objectiveService: ObjectiveServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published private(set) var objectiveItemsViewModels: [ObjectiveItemViewModel] = []
    @Published private(set) var error: BillyError?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var bankAccounts: [String : Account]?
    @Published var showingCreateSheet: Bool = false {
        willSet {
            if newValue == false, showingCreateSheet == true, let needReload = needReload, needReload {
                self.send(action: .reload)
            }
        }
    }
    
    var checkingUserPremiumStatus = false
    private let userSettings: UserSettings
    
    @Published var needReload: Bool? = false
    private var lastDoc: DocumentSnapshot?
    private var lastReached: Bool = false
    private let budgetId: String
    private let loadAmmount = 3
    
    init(userSettings: UserSettings, budgets: [Budget], userService: UserServiceProtocol = UserService(), objectiveService: ObjectiveServiceProtocol = ObjectiveService(), purchaseService: PurchaseServiceProtocol = PurchaseService()) {
        self.userSettings = userSettings
        self.userService = userService
        self.objectiveService = objectiveService
        self.purchaseService = purchaseService
        var budget: Budget
        if let mainBudgetId = self.userSettings.mainBudgetId {
            budget = budgets.first { $0.id == mainBudgetId } ?? budgets[0]
        } else {
            self.userSettings.mainBudgetId =  budgets[0].id
            budget = budgets[0]
        }
        self.bankAccounts = budget.bankAccounts
        self.budgetId = budget.id!
        self.getObjectives()
    }

    enum Action {
        case create
        case loadMore
        case reload
   }
    
    func send(action: Action, objectiveViewModel: ObjectiveItemViewModel? = nil) {
        switch action {
        case .create:
            showingCreateSheet = true
        case .loadMore:
            if let lastId = objectiveViewModel?.id, self.isLastObjective(lastId), !self.lastReached {
                getObjectives()
            }
        case .reload:
            needReload = false
            lastDoc = nil
            lastReached = false
            objectiveItemsViewModels = []
            getObjectives(clearObjectives: true)
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
    
    private func getObjectives(clearObjectives: Bool = false) {
        if self.lastReached {
            return
        }
        
        isLoading = true
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, objectives: [Objective]), BillyError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.objectiveService.getObjectives(budgetId: self.budgetId, lastDoc: self.lastDoc, limit: self.loadAmmount)
            }.sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] objectivesInfo in
                guard let self = self else { return }
                self.error = nil
                if self.lastDoc == objectivesInfo.lastDoc || objectivesInfo.lastDoc == nil {
                    self.lastReached = true
                } else {
                    self.lastDoc = objectivesInfo.lastDoc
                    let newObjectives = objectivesInfo.objectives.map { ObjectiveItemViewModel(objective: $0) }
                    if !clearObjectives {
                        self.objectiveItemsViewModels.append(contentsOf: newObjectives)
                    } else {
                        self.objectiveItemsViewModels = newObjectives
                    }
                }
                self.isLoading = false
            }.store(in: &cancellables)
    }
    
    private func isLastObjective(_ objectiveId: String) -> Bool {
        if let lastId = self.objectiveItemsViewModels.last?.id {
            return lastId == objectiveId
        }
        return false
    }
}

final class ObjectiveDetailViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let objectiveService: ObjectiveServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published private(set) var objectiveItemViewModel: ObjectiveItemViewModel?
    @Published private(set) var error: BillyError?
    @Published private(set) var isLoading: Bool = false
    
    var bankAccounts: [String: Account]?
    var budgetId: String
    
    init(objectiveId: String, budgetId: String, bankAccounts: [String: Account]?, userService: UserServiceProtocol = UserService(), objectiveService: ObjectiveServiceProtocol = ObjectiveService()) {
        self.userService = userService
        self.objectiveService = objectiveService
        self.budgetId = budgetId
        self.bankAccounts = bankAccounts
        self.observeObjective(objectiveId: objectiveId)
    }
    
    var accounts: [Account]? {
        bankAccounts?.compactMap { $1 }
    }
    
    var filteredAccounts: [Account]? {
        accounts?.filter { $0.freeBalance > 0 }
    }
    
    private func observeObjective(objectiveId: String) {
        isLoading = true
        objectiveService.observeObjective(budgetId: self.budgetId, objectiveId: objectiveId).sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] objective in
            guard let self = self else { return }
            self.error = nil
            self.objectiveItemViewModel = .init(objective: objective)
            self.isLoading = false
        }.store(in: &cancellables)
    }
}

final class ObjectiveItemViewModel: ObservableObject {
    @Published var objective: Objective
    @Published var ammountPercentage: Double
    @Published var timePercentage: Double
    
    var timeLeft: Int
    var currentAmmount: Double
    var objectiveTransactions: [AmmountsHistory]?
    var id: String
    var sortedTransactions: [AmmountsHistory]
    
    init(objective: Objective) {
        self.objective = objective
        self.id = objective.id!
        self.timeLeft = objective.dateLimit.daysFromNow
        self.timePercentage = Double(objective.dateLimit.daysFrom(objective.startDate) - timeLeft) / Double(objective.dateLimit.daysFrom(objective.startDate))
        self.objectiveTransactions = objective.accountsAmmount?.flatMap{ $1 }.map { $0 }
        self.currentAmmount = objectiveTransactions?.reduce(0) { $0 + Double($1.ammount) / 100 } ?? 0
        self.ammountPercentage = currentAmmount / (Double(objective.targetAmmount) / 100)
        self.sortedTransactions = objectiveTransactions?.sorted(by: { $0.date > $1.date }) ?? []
    }
    
    var lineChartViewModel: LineChartViewModel {
        var values: Array<Double> = [0.0]
        var labels: Array<String> = [""]
        if let transactions = objectiveTransactions?.sorted(by: { $0.date < $1.date }), transactions.count > 0 {
            var currentDate: Date = transactions[0].date
            var currentTotal = values[0]
            for transaction in transactions {
                currentTotal += Double(transaction.ammount) / 100
                // Verifica se essa data de transaction ja foi inserida no vetor
                if (transaction.date.startOfDay ... transaction.date.endOfDay).contains(currentDate) {
                    if values.count > 1 {
                        values[values.count - 1] = currentTotal
                    } else {
                        values.append(currentTotal)
                        labels.append(transaction.date.getFormattedDateLocalized())
                        //TODO: - labels de acordo com tamanho do vetor para melhorar imagem do grafico
                    }
                // Se ainda nao foi, adiciona nova data
                } else {
                    currentDate = transaction.date
                    values.append(currentTotal)
                    labels.append(transaction.date.getFormattedDateLocalized())
                }
            }
        }
        return .init(ChartData(values: values, labels: labels))
    }
    
    var currentAmmountString: String {
        NumberFormatter.currencyFormatter.string(for: currentAmmount)!
    }
    
    var perMonth: Double {
        ((Double(objective.targetAmmount) / 100) - currentAmmount) / max(1, Double(objective.dateLimit.monthsFromNow + 1))
    }
    
    // TODO: - Arrumar quando for uma unidade tirar do plural
    var timeLeftString: String {
        if timeLeft / 7 < 1 {
            return "\(timeLeft) \(Strings.days.toLocalizedString)"
        } else if timeLeft / 30 < 1 {
            return "\(timeLeft/7) \(Strings.weeks.toLocalizedString)"
        } else if timeLeft / 365 < 1 {
            return "\(timeLeft/30) \(Strings.months.toLocalizedString)"
        } else {
            return "\(timeLeft/365) \(Strings.years.toLocalizedString)"
        }
    }
    
    var isOnSchedule: Bool {
        timeLeft >= 0
    }
}
