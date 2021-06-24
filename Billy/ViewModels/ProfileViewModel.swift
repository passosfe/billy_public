//
//  ProfileViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 17/12/20.
//

import Foundation
import Firebase
import Combine

final class ProfileViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
    private let purchaseService: PurchaseServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published var budgets: [Budget]
    @Published var premiumUserStatus: Bool = false
    @Published var userInfo: User?
    @Published var userProfile: UserProfile?
    
    @Published var showAlert: AlertType?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: BillyError?
    var checkingUserPremiumStatus = false
    
    enum Action {
        case logout
        case forceLogout
        case updateUserInfo
        case updateSubscriptionStatus
        case removeAccount
    }
    
    init(budgets: [Budget], userService: UserServiceProtocol = UserService(), userProfileService: UserProfileServiceProtocol = UserProfileService(), purchaseService: PurchaseServiceProtocol = PurchaseService()) {
        self.userService = userService
        self.userProfileService = userProfileService
        self.purchaseService = purchaseService
        self.budgets = budgets
        userInfo = userService.currentUser
        checkUserSubscriptionStatus()
        observeUserProfile()
    }
    
    func send(action: Action) {
        switch action {
            case .logout:
                if let _ = userInfo?.email {
                    logout()
                } else {
                    showAlert = .logout
                }
        case .forceLogout:
            logout()
        case .updateSubscriptionStatus:
            checkUserSubscriptionStatus()
        case .updateUserInfo:
            userInfo = userService.currentUser
            if let userEmail = userInfo?.email {
                currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                    let userProfile = UserProfile(email: userEmail)
                    return self.userProfileService.create(userProfile, userId: userId)
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
        case .removeAccount:
            removeAccount()
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
    
    private func observeUserProfile() {
        isLoading = true
        currentUserId().flatMap { userId -> AnyPublisher<UserProfile, BillyError> in
            return self.userProfileService.observeUserProfile(userId: userId)
        }.sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] userProfile in
            guard let self = self else { return }
            self.error = nil
            self.userProfile = userProfile
            self.isLoading = false
        }.store(in: &cancellables)
    }
    
    private func checkUserSubscriptionStatus() {
        isLoading = true
        purchaseService.isPremiumUser().sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] isPremiumUser in
            guard let self = self else { return }
            self.error = nil
            self.premiumUserStatus = isPremiumUser
            self.isLoading = false
        }.store(in: &cancellables)
    }
    
    private func logout() -> Void {
        userService.logout().sink { completion in
                switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func removeAccount() -> Void {
        userService.removeAccount().sink { completion in
                switch completion {
                case let .failure(error) :
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func currentUserId() -> AnyPublisher<UserId, BillyError> {
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, BillyError> in
            return Just(user!.uid)
                .setFailureType(to: BillyError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    enum AlertType: String, Identifiable {
        case logout
        case removeAccount
        
        var id: String {
            self.rawValue
        }
    }
}
