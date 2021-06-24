//
//  UserService.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation
import Combine
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

protocol UserServiceProtocol {
    var currentUser: User? { get }
    func currentUserPublisher() -> AnyPublisher<User?, Never>
    func signInAnonymously() -> AnyPublisher<User, BillyError>
    func observeAuthChanges() -> AnyPublisher<User?, Never>
    func linkAccountWithEmail(email: String, password: String) -> AnyPublisher<Void, BillyError>
    func loginWithApple(idTokenString: String, nonce: String, mode: AuthMode) -> AnyPublisher<Void, BillyError>
    func loginWithFacebook(mode: AuthMode) -> AnyPublisher<Void, BillyError>
    func loginWithEmail(email: String, password: String) -> AnyPublisher<Void, BillyError>
    func login(credential: AuthCredential) -> AnyPublisher<Void, BillyError>
    func linkAccount(credential: AuthCredential) -> AnyPublisher<Void, BillyError>
    func logout() -> AnyPublisher<Void, BillyError>
    func removeAccount() -> AnyPublisher<Void, BillyError>
}

final class UserService: UserServiceProtocol {
    let currentUser = Auth.auth().currentUser
    
    func currentUserPublisher() -> AnyPublisher<User?, Never> {
        Just(Auth.auth().currentUser).eraseToAnyPublisher()
    }
    
    func signInAnonymously() -> AnyPublisher<User, BillyError> {
        return Future<User, BillyError> { promise in
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    return promise(.failure(.auth(description: error.localizedDescription)))
                } else if let user = result?.user {
                    return promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func observeAuthChanges() -> AnyPublisher<User?, Never> {
        Publishers.AuthPublisher().eraseToAnyPublisher()
    }
    
    func linkAccountWithEmail(email: String, password: String) -> AnyPublisher<Void, BillyError> {
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        return Future<Void, BillyError> { promise in
            Auth.auth().currentUser?.link(with: emailCredential) { result, error in
                if let error = error {
                    return promise(.failure(.default(description: error.localizedDescription)))
                } else if let user = result?.user {
                    Auth.auth().updateCurrentUser(user) { error in
                        if let error = error {
                            return promise(.failure(.default(description: error.localizedDescription)))
                        } else {
                            return promise(.success(()))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loginWithApple(idTokenString: String, nonce: String, mode: AuthMode) -> AnyPublisher<Void, BillyError> {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        switch mode {
        case .login:
            return self.login(credential: credential)
        case .signup:
            return self.linkAccount(credential: credential)
        }
    }
    
    func loginWithFacebook(mode: AuthMode) -> AnyPublisher<Void, BillyError> {
        guard let accessToken = AccessToken.current else { return Fail(error: .default()).eraseToAnyPublisher() }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        switch mode {
        case .login:
            return self.login(credential: credential)
        case .signup:
            return self.linkAccount(credential: credential)
        }
    }
    
    func loginWithEmail(email: String, password: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func login(credential: AuthCredential) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func linkAccount(credential: AuthCredential) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            Auth.auth().currentUser?.link(with: credential) { result, error in
                if let error = error {
                    return promise(.failure(.default(description: error.localizedDescription)))
                } else if let user = result?.user {
                    Auth.auth().updateCurrentUser(user) { error in
                        if let error = error {
                            return promise(.failure(.default(description: error.localizedDescription)))
                        } else {
                            return promise(.success(()))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.default(description: error.localizedDescription)))
            }
        }.eraseToAnyPublisher()
    }
    
    func removeAccount() -> AnyPublisher<Void, BillyError> {
        return currentUserPublisher().flatMap { user -> AnyPublisher<Void, BillyError> in
            return Future<Void, BillyError> { promise in
                user?.delete { error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    promise(.success(()))
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
