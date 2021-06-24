//
//  NotificationViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 28/12/20.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

final class NotificationViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    @Published var error: BillyError?
    
    @Published var newPermissions: [NewPermission] = []
    @Published private(set) var isLoading: Bool = false
    
    enum Action {
        case accept
        case reject
    }
    
    init(newPermissions: [NewPermission], userService: UserServiceProtocol = UserService(), userProfileService: UserProfileServiceProtocol = UserProfileService()) {
        self.userService = userService
        self.userProfileService = userProfileService
        self.newPermissions = newPermissions
    }
    
    func send(action: Action, newPermission: NewPermission) {
        switch action {
        case .accept:
            currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                return self.userProfileService.acceptUserPermission(userId: userId, newPermission: newPermission)
            }
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("success")
                }
            } receiveValue: { _ in
                print("success")
            }.store(in: &cancellables)
        case .reject:
            currentUserId().flatMap { userId -> AnyPublisher<Void, BillyError> in
                return self.userProfileService.rejectUserPermission(userId: userId, newPermission: newPermission)
            }
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        self.error = error
                    case .finished:
                        print("success")
                }
            } receiveValue: { _ in
                print("success")
            }.store(in: &cancellables)
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
