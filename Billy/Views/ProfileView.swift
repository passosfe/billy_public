//
//  ProfileView.swift
//  Billy
//
//  Created by Felipe Passos on 17/12/20.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showSubscriptionPopUp: Bool
    @State private var isMainBudgetExpanded = false
    @State private var isSignUpExpanded = false
    @State private var isNotificationsExpanded = false
    @State var activeSheet: SheetType?
    
    var activeBudget: Budget {
        if let budget = viewModel.budgets.first(where: { $0.id == settings.mainBudgetId }) {
            return budget
        } else if let budget = viewModel.budgets.first {
            settings.mainBudgetId = budget.id
            return budget
        } else {
            return Budget(id: "", title: "", userPermissions: ["":.init(permission: .edit)])
        }
    }
    
    @ViewBuilder
    func goToNotifications() -> some View {
        if let userProfile = viewModel.userProfile {
            NavigationLink(
                destination: NavigationLazyView(NotificationsView(viewModel: .init(newPermissions: userProfile.newPermissions ?? []))),
                isActive: $isNotificationsExpanded
                ) {
                Button(action: {
                    isNotificationsExpanded = true
                }, label: {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.title)
                        if let newPermissions = userProfile.newPermissions, newPermissions.count > 0 {
                            VStack {
                                HStack {
                                    Circle()
                                        .fill(Color.negativeRed)
                                        .frame(width: 10, height: 10, alignment: .topLeading)
                                        .padding(5)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                })
                .disabled(isMainBudgetExpanded)
            }.disabled(isMainBudgetExpanded)
        }
    }
    
    var goToSignIn: some View {
        NavigationLink(
            destination: NavigationLazyView(LoginSignupView(viewModel: .init(mode: .signup, isPushed: .init(get: {
                isSignUpExpanded
            }, set: { isActive in
                if isActive == false {
                    viewModel.send(action: .updateUserInfo)
                    isSignUpExpanded = isActive
                }
            })))),
            isActive: $isSignUpExpanded
            ) {
            Button(action: {
                isSignUpExpanded = true
            }, label: {
                Text(Strings.register.toLocalizedString)
            })
            .padding()
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isMainBudgetExpanded)
        }.disabled(isMainBudgetExpanded)
    }
    
    var premiumUserStatus: some View {
        Button(action: {
            if !viewModel.premiumUserStatus {
                self.activeSheet = .subscribe
            }
        }, label: {
            HStack {
                Text("🏅")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text(viewModel.premiumUserStatus ? Strings.congratulations.toLocalizedString : Strings.becomePremium.toLocalizedString)
                        .font(.headline)
                    Text(viewModel.premiumUserStatus ? Strings.alreadyPremium.toLocalizedString : Strings.subscribeAndUnlock.toLocalizedString)
                        .font(.subheadline)
                }
            }
        })
        .padding(.horizontal)
        .padding(.horizontal)
        .buttonStyle(PrimaryButtonStyle())
        .fixedSize(horizontal: false, vertical: true)
        .disabled(viewModel.premiumUserStatus)
    }
    
    var removeAccount: some View {
        Button(action: {
            viewModel.showAlert = .removeAccount
        }, label: {
            Text(Strings.deleteAccount.toLocalizedString)
                .foregroundColor(.negativeRed)
        })
        .padding([.horizontal, .bottom])
        .disabled(isMainBudgetExpanded)
    }
    
    var logout: some View {
        Button(action: {
            viewModel.send(action: .logout)
        }, label: {
            Text(Strings.logout.toLocalizedString)
                .foregroundColor(.negativeRed)
        })
        .padding()
        .disabled(isMainBudgetExpanded)
    }
    
    @ViewBuilder
    func usersPermissions() -> some View {
        VStack {
            HStack {
                Text(Strings.permissions.toLocalizedString)
                    .font(.headline)
                Spacer()
                Button(action: {
                    viewModel.insideLimit(for: .maxUserPerBudget, value: activeBudget.userPermissions.count, ifInside: {
                        activeSheet = .permission
                    }, ifOutside: {
                        showSubscriptionPopUp = true
                    })
                }, label: {
                    Text(Strings.add.toLocalizedString)
                })
            }.padding()
            VStack {
                ForEach(activeBudget.userPermissions.sorted(by: { $0.key > $1.key }), id: \.key) { key, value in
                    HStack {
                        if key == viewModel.userInfo?.uid {
                            Text(Strings.me.toLocalizedString)
                                .font(.callout)
                        } else if let email = value.email, let userEmail = viewModel.userInfo?.email, email == userEmail {
                            Text(Strings.me.toLocalizedString)
                                .font(.callout)
                        } else if let email = value.email {
                            Text(email)
                                .font(.callout)
                        }
                        Spacer()
                        Text(value.permission.toLocalizedString)
                            .foregroundColor(.fintechGreen)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.fintechGreen, lineWidth: 2)
                            )
                    }.padding(.bottom)
                }
            }
            .padding([.horizontal, .top])
            .cardify()
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
        }
    }
    
    func userInfo(with avatarSize: CGFloat) -> some View {
            VStack {
                Image("avatar")
                    .resizable()
                    .frame(width: avatarSize, height: avatarSize)
                if let _ = viewModel.userInfo?.email {
                VStack {
                    if let userEmail = viewModel.userInfo?.email {
                        if let userName = viewModel.userInfo?.displayName {
                            Text(userName)
                        }
                        
                        Text(userEmail)
                    }
                }
                .padding()
            } else {
                goToSignIn
            }
        }
    }
    
    var mainBudgetDropdown: some View {
        VStack {
            HStack {
                Text(Strings.mainBudget.toLocalizedString)
                    .font(.headline)
                Spacer()
            }
            DisclosureGroup("\(activeBudget.title)", isExpanded: $isMainBudgetExpanded) {
                VStack {
                    ForEach(viewModel.budgets.filter { $0.id != settings.mainBudgetId }) { budget in
                        HStack {
                            Text(budget.title)
                                .onTapGesture {
                                    settings.mainBudgetId = budget.id!
                                    withAnimation {
                                        isMainBudgetExpanded.toggle()
                                    }
                                }
                            Spacer()
                        }
                        .padding(.top)
                    }
                    
                    HStack {
                        Text(Strings.create.toLocalizedString)
                            .foregroundColor(.fintechGreen)
                            .onTapGesture {
                                viewModel.insideLimit(for: .maxBudgets, value: viewModel.budgets.count, ifInside: {
                                    activeSheet = .budget
                                    withAnimation {
                                        isMainBudgetExpanded.toggle()
                                    }
                                }, ifOutside: {
                                    showSubscriptionPopUp = true
                                    withAnimation {
                                        isMainBudgetExpanded.toggle()
                                    }
                                })
                            }
                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .padding()
            .cardify()
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                withAnimation {
                    isMainBudgetExpanded.toggle()
                }
            }
        }
        .padding([.horizontal, .top])
        .scaleEffect(isMainBudgetExpanded ? dropdownScaleEffect : 1)
    }
    
    var content: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    userInfo(with: geometry.size.width * 0.4)
                        .blur(radius: isMainBudgetExpanded ? blurAmmout : 0)
                    premiumUserStatus
                        .blur(radius: isMainBudgetExpanded ? blurAmmout : 0)
                    mainBudgetDropdown
                    usersPermissions()
                        .blur(radius: isMainBudgetExpanded ? blurAmmout : 0)
                    Spacer()
                    logout
                        .blur(radius: isMainBudgetExpanded ? blurAmmout : 0)
                    removeAccount
                        .blur(radius: isMainBudgetExpanded ? blurAmmout : 0)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                content
            }
            .navigationBarItems(trailing: goToNotifications())
            .navigationBarTitle(Strings.profile.toLocalizedString)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(item: $viewModel.showAlert, content: { (item) -> Alert in
            switch item {
            case .logout:
                return Alert(title: Text(Strings.warning.toLocalizedString),
                      message: Text(Strings.logoutWarningMessage.toLocalizedString),
                      primaryButton: .cancel({
                        viewModel.showAlert = nil
                      }),
                      secondaryButton: .destructive(Text(Strings.leaveAnyway.toLocalizedString), action: {
                        viewModel.showAlert = nil
                        settings.mainBudgetId = nil
                        viewModel.send(action: .forceLogout)
                      }))
            case .removeAccount:
                return Alert(title: Text(Strings.warning.toLocalizedString),
                             message: Text(Strings.deleteAccountWarning.toLocalizedString),
                      primaryButton: .cancel({
                        viewModel.showAlert = nil
                      }),
                      secondaryButton: .destructive(Text(Strings.confirmation.toLocalizedString), action: {
                        viewModel.showAlert = nil
                        settings.mainBudgetId = nil
                        viewModel.send(action: .removeAccount)
                      }))
            }
        })
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .budget:
                CreateBudgetView(viewModel: .init(isShowing: .init(get: {
                    self.activeSheet == .budget
                }, set: { isShowing in
                    activeSheet = isShowing ? .budget : nil
                })))
            case .permission:
                AddUserPermissionView(viewModel: .init(budgetId: settings.mainBudgetId!, budgetName: viewModel.budgets.first(where: { $0.id == settings.mainBudgetId })!.title, isShowing: .init(get: {
                    self.activeSheet == .permission
                }, set: { isShowing in
                    activeSheet = isShowing ? .permission : nil
                })))
            case .subscribe:
                SubscriptionView(viewModel: .init(isShowing: .init(get: {
                    self.activeSheet == .subscribe
                }, set: { isShowing in
                    activeSheet = isShowing ? .subscribe : nil
                    if !isShowing {
                        viewModel.send(action: .updateSubscriptionStatus)
                    }
                })))
            }
        }
    }
    
    // MARK: -Drawing Constants
    private let blurAmmout: CGFloat = 5.0
    private let dropdownScaleEffect: CGFloat = 1.05
    
    enum SheetType: String, Identifiable {
        case budget
        case permission
        case subscribe
        
        var id: String {
            rawValue
        }
    }
}
