//
//  LoginSignupViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 12/11/20.
//

import Foundation
import Combine
import SwiftUI
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices

final class LoginSignupViewModel: ObservableObject {
    let mode: AuthMode
    
    @Published var emailText = ""
    @Published var passwordText = ""
    @Published var isValid = false
    @Published var isLoading = false
    
    @Binding var isPushed: Bool
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    
    init(mode: AuthMode,
         userService: UserServiceProtocol = UserService(),
         isPushed: Binding<Bool>) {
        self.mode = mode
        self.userService = userService
        self._isPushed = isPushed
    }
    
    var title: String {
        switch mode {
        case .login:
            return Strings.welcomeBack.toLocalizedString
        case .signup:
            return Strings.createAccount.toLocalizedString
        }
    }
    
    var subtitle: String {
        switch mode {
        case .login:
            return Strings.enterWithAccount.toLocalizedString
        case .signup:
            return Strings.registerAndKeep.toLocalizedString
        }
    }
    
    func buttonTitle(for provider: Provider) -> String {
        var pronoun = ""
        switch provider {
        case .facebook:
            pronoun = Strings.pronounO.toLocalizedString
        case .email:
            pronoun = Strings.pronounO.toLocalizedString
        case .apple:
            break
        }
        
        switch mode {
        case .login:
            return "\(Strings.signInWith.toLocalizedString)\(pronoun)\(provider.rawValue.capitalizingFirstLetter())"
        case .signup:
            return "\(Strings.signUpWith.toLocalizedString)\(pronoun)\(provider.rawValue.capitalizingFirstLetter())"
        }
    }
    
    func tappedActionButton(for provider: Provider, appleAuthResults: ASAuthorization? = nil, currentNonce: String? = nil) {
        switch mode {
        case .login:
            login(for: provider, appleAuthResults: appleAuthResults, currentNonce: currentNonce)
        case .signup:
            signup(for: provider, appleAuthResults: appleAuthResults, currentNonce: currentNonce)
        }
    }
    
    func login(for provider: Provider, appleAuthResults: ASAuthorization? = nil, currentNonce: String? = nil) {
        isLoading = true
        switch provider {
        case .email:
            userService.loginWithEmail(email: emailText, password: passwordText)
                .sink { completion in
                    self.isLoading = false
                    switch completion {
                    case let .failure(error):
                        print(error.localizedDescription)
                    case .finished: break
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        case .facebook:
            self.getFBUserData()
        case .apple:
            switch appleAuthResults!.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                        guard let nonce = currentNonce else {
                          fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = appleIDCredential.identityToken else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                          return
                        }
                    
                    self.userService.loginWithApple(idTokenString: idTokenString, nonce: nonce, mode: .login)
                        .sink { completion in
                            self.isLoading = false
                            switch completion {
                            case let .failure(error):
                                print(error.localizedDescription)
                            case .finished:
                                self.isPushed = false
                            }
                        } receiveValue: { _ in
                            self.isLoading = false
                            self.isPushed = false
                        }
                        .store(in: &self.cancellables)
            default:
                break
                        
                    }
        }
    }
    
    func signup(for provider: Provider, appleAuthResults: ASAuthorization? = nil, currentNonce: String? = nil) {
        self.isLoading = true
        switch provider {
        case .email:
            userService.linkAccountWithEmail(email: emailText, password: passwordText).sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("Finished")
                    self?.isPushed = false
                }
            } receiveValue: {  _ in }
            .store(in: &cancellables)
        case .facebook:
            self.getFBUserData()
        case .apple:
            switch appleAuthResults!.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                        guard let nonce = currentNonce else {
                          fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = appleIDCredential.identityToken else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                          return
                        }
                    
                    self.userService.loginWithApple(idTokenString: idTokenString, nonce: nonce, mode: .signup)
                        .sink { completion in
                            self.isLoading = false
                            switch completion {
                            case let .failure(error):
                                print(error.localizedDescription)
                            case .finished:
                                self.isPushed = false
                            }
                        } receiveValue: { _ in
                            self.isLoading = false
                            self.isPushed = false
                        }
                        .store(in: &self.cancellables)
            default:
                break
                        
                    }
        }
    }
}

enum AuthMode {
    case login
    case signup
}

extension LoginSignupViewModel {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email) && email.count > 5
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count > 5
    }
}

extension LoginSignupViewModel {
    enum Provider: String {
        case email
        case facebook
//            case google TODO
        case apple
    }
}

extension LoginSignupViewModel {
    func getFBUserData(){
        self.userService.loginWithFacebook(mode: self.mode)
            .sink { completion in
                self.isLoading = false
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    self.isPushed = false
                }
            } receiveValue: { _ in
                self.isLoading = false
                self.isPushed = false
            }
            .store(in: &self.cancellables)
    }
}
