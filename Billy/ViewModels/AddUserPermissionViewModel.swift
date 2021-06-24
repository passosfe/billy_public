//
//  AddUserPermissionViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 27/12/20.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class AddUserPermissionViewModel: ObservableObject {
    @Published var newUserEmail: String = ""
    @Published var permissionType: PermissionTypes = .edit
    
    lazy var newUserEmailNonEmptyValidation: ValidationPublisher = {
        $newUserEmail.nonEmptyValidator("\(Strings.formTitle.toLocalizedString)\(Strings.mustNotBeEmpty.toLocalizedString)")
    }()
    
    lazy var newUserEmailValidValidation: ValidationPublisher = {
        $newUserEmail.matcherValidation(NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"), "Insira um e-mail válido")
    }()
    
    lazy var allUserEmailValidation: ValidationPublisher = {
        Publishers.CombineLatest(
            newUserEmailNonEmptyValidation,
            newUserEmailValidValidation
            ).map { v1, v2 in
                return [v1, v2].allSatisfy { $0.isSuccess } ? .success : .failure(message: "")
            }.eraseToAnyPublisher()
        }()
    
    @Published var error: BillyError?
    @Published var isLoading: Bool = false
    @Binding var isShowing: Bool
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    private let userProfileService: UserProfileServiceProtocol
    
    var actionTypeText: String = Strings.newMale.toLocalizedString
    var buttonText: String = Strings.create.toLocalizedString
    var permissions: [PermissionTypes] = PermissionTypes.allCases
    
    private let budgetId: String
    private let budgetName: String
    
    enum Action {
        case create
    }
    
    init(budgetId: String, budgetName: String, isShowing: Binding<Bool>, userService: UserServiceProtocol = UserService(), userProfileService: UserProfileServiceProtocol = UserProfileService()) {
        self.userService = userService
        self.userProfileService = userProfileService
        self.budgetId = budgetId
        self.budgetName = budgetName
        self._isShowing = isShowing
    }
    
    func send(action: Action) {
        switch action {
            case .create:
                isLoading = true
                currentUserEmail().flatMap { email -> AnyPublisher<Void, BillyError> in
                    return self.addPermission(fromEmail: email)
                }
                .sink { completion in
                    switch completion {
                        case let .failure(error):
                            self.error = error
                        case .finished:
                            print("finished")
                            self.isShowing = false
                    }
                    self.isLoading = false
                } receiveValue: { _ in
                    print("success")
                }.store(in: &cancellables)
        }
    }
    
    private func addPermission(fromEmail: String) -> AnyPublisher<Void, BillyError> {
        let newPermission = NewPermission(
            fromEmail: fromEmail,
            toEmail: self.newUserEmail,
            budgetID: self.budgetId,
            budgetName: self.budgetName,
            permissionType: self.permissionType
        )
        
        Analytics.logEvent("newUserPermission", parameters: nil)
        
        return userProfileService.addUserPermission(newPermission)
    }
        
    private func currentUserEmail() -> AnyPublisher<String, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.email!)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
