//
//  ContentView.swift
//  Billy
//
//  Created by Felipe Passos on 06/11/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showSubscriptionPopUp: Bool
    @State var tab = TabButton.TabButtonTitle.month
    @State var bankAccountAlert = false
    @State private var isTransactionsActive = false
    @State private var isCategoriesActive = false
    @State var activeSheet: Sheet?
    @ObservedObject var chartValue = ChartValue()
    
    var mainChart: some View {
        VStack {
            MainChartTabs(tab: $tab)
            
            if !chartValue.interactionInProgress {
                HStack(alignment: .firstTextBaseline, spacing: spendingValuesSpacing) {
                    Text(NumberFormatter.currencyFormatter.string(for: viewModel.totals[tab])!)
                        .fontWeight(.bold)
                    Text("/ \(NumberFormatter.currencyFormatter.string(for: viewModel.totalLimits(for: tab))!)")
                        .font(.caption2)
                }
                
                Text(tab.getTitleAdverb())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text(NumberFormatter.currencyFormatter.string(for: chartValue.currentValue)!)
                    .fontWeight(.bold)
                
                Text(chartValue.currentLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            LineChartView(lineChartViewModel: viewModel.lineChartViewModel[tab] ?? LineChartViewModel(), themeColor: .fintechGreen)
                .frame(height: chartHeight)
                .environmentObject(chartValue)
        }
        .padding()
    }
    
    var categoriesBox: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Strings.categories.toLocalizedString)
                    .font(.headline)
                Spacer()
                NavigationLink(
                    destination: NavigationLazyView(CategoriesPageView(categoriesListViewModel: viewModel.categoriesListViewModel, availableCategories: viewModel.availableCategories)),
                    isActive: $isCategoriesActive
                    ) {
                    Button(action: {
                        isCategoriesActive = true
                    }) {
                        Text(Strings.seeAll.toLocalizedString)
                    }
                }

            }.padding(.horizontal)
            
            CategoriesBoxView(categoriesListViewModel: viewModel.categoriesListViewModel)
        }
    }
    
    var transactionsBox: some View {
        VStack(spacing: 10) {
            HStack {
                Text(Strings.transactions.toLocalizedString)
                    .font(.headline)
                Spacer()
                NavigationLink(
                    destination: NavigationLazyView(TransactionsPageView(transactionListViewModel: .init(budgetId: settings.mainBudgetId ?? "1", bankAccounts: viewModel.bankAccounts, isInfiniteScroll: true))),
                    isActive: $isTransactionsActive
                    ) {
                    Button(action: {
                        isTransactionsActive = true
                    }) {
                        Text(Strings.seeAll.toLocalizedString)
                    }
                }
            }.padding([.bottom, .horizontal])
            
            TransactionListView(viewModel: viewModel.transactionListViewModel)
                .padding(.bottom)
        }.padding(.bottom)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            mainChart
                            categoriesBox
                            transactionsBox
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                if let bankAccounts = viewModel.bankAccounts, bankAccounts.count > 0 {
                    viewModel.send(action: .create)
                } else {
                    bankAccountAlert.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .font(.title)
            })
            .navigationBarTitle(Strings.home.toLocalizedString)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $viewModel.showingActionSheet) {
            ActionSheet(title: Text(Strings.create.toLocalizedString), message: Text(Strings.selectToCreate.toLocalizedString), buttons: [
                .default(Text(Strings.transaction.toLocalizedString)) { self.activeSheet = .transaction },
                .default(Text(Strings.monthLimit.toLocalizedString)) {
                    viewModel.insideLimit(for: .maxCategoryLimits, value: viewModel.categoriesListViewModel.itemViewModels.count, ifInside: {
                        self.activeSheet = .categoryLimit
                    }, ifOutside: {
                        showSubscriptionPopUp = true
                    })
                },
                .cancel()
            ])
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .transaction:
                CreateTransactionView(viewModel: .init(budgetId: settings.mainBudgetId!, bankAccounts: viewModel.bankAccounts!, isShowing: .init(get: {
                    self.activeSheet == .transaction
                }, set: { isShowing in
                    activeSheet = isShowing ? .transaction : nil
                })))
            case .categoryLimit:
                // TODO: - Adaptar para quando utilizar categorias personalizadas
                CreateCategoryLimitView(viewModel: .init(budgetId: settings.mainBudgetId!, availableCategories: viewModel.availableCategories, isShowing: .init(get: {
                    self.activeSheet == .categoryLimit
                }, set: { isShowing in
                    activeSheet = isShowing ? .categoryLimit : nil
                })))
            }
        }
        .alert(isPresented: $bankAccountAlert, content: { () -> Alert in
            Alert(title: Text("Error!"),
                  message: Text("teste"),
                  primaryButton: .default(Text("tes"), action: {
                    
                  }),
                  secondaryButton: .cancel(Text("OK"), action: {
                    
                  }))
        })
    }
    
    // MARK: -Drawing Constants
    
    private let padding: CGFloat = 10.0
    private let cornerRadius: CGFloat = 20.0
    private let spendingValuesSpacing: CGFloat = 2.0
    private let chartHeight: CGFloat = 150.0
}

enum Sheet: String, Identifiable {
    case transaction
    case categoryLimit
    
    var id: String {
        rawValue
    }
}
