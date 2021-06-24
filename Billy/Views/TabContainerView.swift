//
//  TabContainerView.swift
//  Billy
//
//  Created by Felipe Passos on 06/11/20.
//

import SwiftUI

struct TabContainerView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: TabContainerViewModel
    @State var showSubscribePopUp: Bool = false
    
    init (viewModel: TabContainerViewModel) {
        self.viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.tabItemViewModels, id: \.self) { viewModel in
                tabView(for: viewModel.type)
                    .tabItem {
                        Image(systemName: viewModel.imageName)
                        Text(viewModel.title)
                    }
                    .tag(viewModel.type)
            }
        }.accentColor(.fintechGreen)
        .onAppear {
            AppReviewRequest.requestReviewIfNeeded()
        }
        .onChange(of: viewModel.budgets, perform: { value in
            if let mainBudgetId = settings.mainBudgetId {
                if viewModel.budgets.first?.id != "placeholder", viewModel.budgets.first(where: { $0.id == mainBudgetId }) == nil {
                    settings.mainBudgetId = viewModel.budgets.first?.id
                }
            } else if viewModel.budgets.count > 0, viewModel.budgets.first?.id != "placeholder" {
                settings.mainBudgetId = viewModel.budgets.first?.id
            }
        })
        .subscriptionPupUp(show: showSubscribePopUp,
            actionIfSubscribe: {
                showSubscribePopUp = false
            }, dismiss: {
                showSubscribePopUp = false
            })
    }
    
    @ViewBuilder
    private func tabView(for viewModel: TabItemViewModel.TabItemType) -> some View {
        switch viewModel {
        case .home:
            HomeView(viewModel: .init(userSettings: settings, budgets: self.viewModel.budgets), showSubscriptionPopUp: $showSubscribePopUp)
                .environmentObject(settings)
        case .accounts:
            AccountsView(viewModel: .init(userSettings: settings, budgets: self.viewModel.budgets), showSubscriptionPopUp: $showSubscribePopUp)
                .environmentObject(settings)
        case .objectives:
            ObjectivesView(viewModel: .init(userSettings: settings, budgets: self.viewModel.budgets), showSubscriptionPopUp: $showSubscribePopUp)
                .environmentObject(settings)
        case .profile:
            ProfileView(viewModel: .init(budgets: self.viewModel.budgets), showSubscriptionPopUp: $showSubscribePopUp)
                .environmentObject(settings)
        }
    }
    
    // MARK: -Drawing Constants
    
    private let blurRadius: CGFloat = 20.0
}

