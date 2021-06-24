//
//  CreateObjectiveViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class CreateObjectiveViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var dateLimit: Date = Date().addDays(7)
    @Published var targetAmmount: String = ""
    
    var targetAmmountValue: Double {
        (Double(targetAmmount) ?? 0.0) / 100
    }
    
    lazy var titleValidation: ValidationPublisher = {
        $title.nonEmptyValidator("\(Strings.formTitle.toLocalizedString)\(Strings.mustNotBeEmpty.toLocalizedString)")
    }()
    
    lazy var ammountValidation: ValidationPublisher = {
        $targetAmmount.aboveValidation(0, errorMessage: "\(Strings.formValue.toLocalizedString)\(Strings.mustBeAboveOf.toLocalizedString)\(NumberFormatter.currencyFormatter.string(from: 0)!)")
    }()
    
    lazy var allValidation: ValidationPublisher = {
        Publishers.CombineLatest(
            titleValidation,
            ammountValidation
            ).map { v1, v2 in
                return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
            }.eraseToAnyPublisher()
        }()
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let objectiveService: ObjectiveServiceProtocol
    
    private let budgetId: String
    @Binding var isShowing: Bool
    @Binding var needReload: Bool?
    private var objectiveToEdit: Objective?
    
    var actionTypeText: String = Strings.newMale.toLocalizedString
    var buttonText: String = Strings.create.toLocalizedString
    
    enum Action {
        case saveObjective
    }
    
    init(budgetId: String, isShowing: Binding<Bool>, needReload: Binding<Bool?> = .constant(nil), editObjective: Objective? = nil, userService: UserServiceProtocol = UserService(), objectiveService: ObjectiveServiceProtocol = ObjectiveService()) {
        if let objective = editObjective {
            self.objectiveToEdit = objective
            self.actionTypeText = Strings.editAction.toLocalizedString
            self.buttonText = Strings.save.toLocalizedString
            self.title = objective.title
            self.description = objective.description ?? ""
            self.dateLimit = objective.dateLimit
            self.targetAmmount = String(objective.targetAmmount)
        }
        self._isShowing = isShowing
        self._needReload = needReload
        self.budgetId = budgetId
        self.userService = userService
        self.objectiveService = objectiveService
    }
    
    func send(action: Action) {
        switch action {
            case .saveObjective:
                isLoading = true
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    if let _ = self.objectiveToEdit {
                        return self.updateTransaction()
                    }
                    return self.createObjective()
                }
                .sink { completion in
                    self.isLoading = false
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            self.needReload = true
                            self.isShowing = false
                            print("finished")
                    }
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func createObjective() -> AnyPublisher<Void, BillyError> {
        let objective = Objective(
            title: title,
            description: description,
            dateLimit: dateLimit,
            startDate: Date(),
            targetAmmount: Int(targetAmmountValue * 100)
        )
        
        Analytics.logEvent("newObjective", parameters: nil)
        
        return objectiveService.create(objective, budgetId: budgetId).eraseToAnyPublisher()
    }
    
    private func updateTransaction() -> AnyPublisher<Void, BillyError> {
        let objective = Objective(
            title: title,
            description: description,
            dateLimit: dateLimit,
            startDate: objectiveToEdit!.startDate,
            targetAmmount: Int(targetAmmountValue * 100),
            accountsAmmount: objectiveToEdit!.accountsAmmount
        )
        
        return objectiveService.updateObjective(objective, objectiveID: objectiveToEdit!.id!, budgetId: budgetId).eraseToAnyPublisher()
    }
        
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
