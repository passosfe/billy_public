//
//  BillyApp.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI
import Firebase
import FBSDKCoreKit
import Purchases
//import UserNotifications

@main
struct BillyApp: App {
    @StateObject private var appState = AppState()
    var settings = UserSettings()
    
    init() {
//        setupNotifications()
        setupFirebase()
        setupRevenueCat()
        let _ = RCValues.sharedInstance
    }
    
//    func setupNotifications() {
//        Messaging.messaging().isAutoInitEnabled = true
//
//        let notificationCenter = UNUserNotificationCenter.current()
//
//        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
//
//        notificationCenter.requestAuthorization(options: options) {
//            (didAllow, error) in
//            if !didAllow {
//                print("User has declined notifications")
//            }
//        }
//
//        UIApplication.shared.registerForRemoteNotifications()
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
    
    func setupFirebase() {
        print("setting up firebase")
        FirebaseApp.configure()
        
        #if DEBUG
            print("Using the Firebase Emulator for Cloud Firestore, running on port 8080")
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings

            Auth.auth().useEmulator(withHost:"localhost", port:9099)
        #endif
    }
    
    func setupRevenueCat() {
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "uTdZaODMsxlRSizROgkhnfLdfcXGGIPU")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isloading {
                    SplashView()
                } else if appState.isloggedIn {
                    TabContainerView(viewModel: .init(userSettings: settings))
                        .environmentObject(settings)
                } else {
                    OnboardingView()
                }
            }
            // Facebook
            .onOpenURL(perform: { url in
                ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
            })
        }
    }
}

class AppState: ObservableObject {
    @Published private(set) var isloggedIn = false
    @Published var isloading: Bool = true
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
        userService
            .observeAuthChanges()
            .map { user in
                self.isloading = false
                return user != nil
            }
            .assign(to: &$isloggedIn)
    }
}

