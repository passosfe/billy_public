//
//  LoginSignupView.swift
//  Billy
//
//  Created by Felipe Passos on 18/12/20.
//

import SwiftUI
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit
import FacebookCore
import FacebookLogin

struct LoginSignupView: View {
    @ObservedObject var viewModel: LoginSignupViewModel
    @State var currentNonce: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var facebookButton: some View {
        Button(action: {
            fbLogin()
        }, label: {
                
            HStack {
                Spacer()
                Image("facebookLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical)
                Text(viewModel.buttonTitle(for: .facebook))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 6)
                            .fill(Color.facebookBlue))
            .frame(height: 50)
            .padding(.horizontal, 30)
        })
    }
    
    var appleButton: some View {
        SignInWithAppleButton(viewModel.mode == .login ? .signIn : .signUp,
            onRequest: { request in
                let nonce = randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            },
            onCompletion: { result in
                switch result {
                  case .success(let authResults):
                    viewModel.tappedActionButton(for: .apple, appleAuthResults: authResults, currentNonce: currentNonce)
                     default:
                          break
                  }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .padding(.horizontal, 30)
    }
    
    var googleButton: some View {
        Button(action: {
            fbLogin()
        }, label: {
            Text("Cadastrar com Google")
        })
    }
    
    var content: some View {
        GeometryReader { geometry in
            VStack {
                Image("avatar")
                    .resizable()
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                Text(viewModel.title)
                    .font(.headline)
                Text(viewModel.subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                facebookButton
                    .padding()
                appleButton
                    .padding(.horizontal)
                
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            if viewModel.isLoading {
                ProgressView()
            } else {
                content
            }
        }
    }
}

extension LoginSignupView {
    private func fbLogin(){
        let cont = UIHostingController(rootView: self)
        let fbLoginManager: LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: cont) { (result, err) in
            if err != nil{
                // TODO: mensagem de erro
                print("Process error")
            }else if result?.isCancelled == true{
                print("Cancelled")
            }else{
                print("Logged in")
                viewModel.isLoading = true
                viewModel.tappedActionButton(for: .facebook)
            }
        }
    }
}

extension LoginSignupView {
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

struct LoginSignupView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignupView(viewModel: .init(mode: .signup, isPushed: .constant(true)))
    }
}
