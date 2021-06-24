//
//  ObjectivesView.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import SwiftUI

struct ObjectivesView: View {
    @ObservedObject var viewModel: ObjectivesViewModel
    @Binding var showSubscriptionPopUp: Bool
    @EnvironmentObject var settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @State private var detailsActive = false
    
    //TODO: - Filtrar concluidos e cancelados
    let columns = [
        GridItem(.adaptive(minimum: 500, maximum: 700))
    ]
    
    var items: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns) {
                // TODO: - Loading skeleton
                // TODO: - Atualizar apos voltar da pagina de detalhes
                ForEach(viewModel.objectiveItemsViewModels.indices) { index in
                    if let itemId = viewModel.objectiveItemsViewModels.last?.id, itemId == viewModel.objectiveItemsViewModels[index].id {
                        VStack {
                            NavigationLink(
                                destination: NavigationLazyView(ObjectiveDetailView(viewModel: .init(objectiveId: viewModel.objectiveItemsViewModels[index].objective.id!, budgetId: settings.mainBudgetId!, bankAccounts: viewModel.bankAccounts)))) {
                                    ObjectiveItemView(viewModel: viewModel.objectiveItemsViewModels[index], title: viewModel.objectiveItemsViewModels[index].objective.title)
                                        .cardify()
                                        .padding()
                                }.accentColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        .onAppear {
                                self.viewModel.send(action: .loadMore, objectiveViewModel: viewModel.objectiveItemsViewModels[index])
                        }
                    } else {
                        VStack {
                            NavigationLink(
                                destination: NavigationLazyView(ObjectiveDetailView(viewModel: .init(objectiveId: viewModel.objectiveItemsViewModels[index].objective.id!, budgetId: settings.mainBudgetId!, bankAccounts: viewModel.bankAccounts)))) {
                                ObjectiveItemView(viewModel: viewModel.objectiveItemsViewModels[index], title: viewModel.objectiveItemsViewModels[index].objective.title)
                                    .cardify()
                                    .padding()
                            }.accentColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                }
            }
        }
    }
    
    var noItemsToShow: some View {
        Text(Strings.registerFirstObjective.toLocalizedString)
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.vertical, noItemsVerticalPadding)
            .padding(.horizontal, noItemsHorizontalPadding)
    }
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.objectiveItemsViewModels.count > 0 {
            items
        } else if !viewModel.isLoading {
            noItemsToShow
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                content()
            }
            .navigationBarItems(trailing: Button(action: {
                viewModel.insideLimit(for: .maxObjectives, value: viewModel.objectiveItemsViewModels.count, ifInside: {
                    viewModel.showingCreateSheet = true
                }, ifOutside: {
                    showSubscriptionPopUp = true
                })
            }) {
                Image(systemName: "plus")
                    .font(.title)
            })
            .navigationBarTitle(Strings.objectives.toLocalizedString)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.showingCreateSheet) {
            CreateObjectiveView(viewModel: .init(budgetId: settings.mainBudgetId!, isShowing: $viewModel.showingCreateSheet, needReload: $viewModel.needReload))
        }
    }
    
    // MARK: -Drawing Constants
    
    private let padding: CGFloat = 10.0
    private let cornerRadius: CGFloat = 20.0
    private let spendingValuesSpacing: CGFloat = 2.0
    private let chartHeight: CGFloat = 150.0
    private let noItemsHorizontalPadding: CGFloat = 20.0
    private let noItemsVerticalPadding: CGFloat = 60.0
}

struct ObjectiveDetailView: View {
    @ObservedObject var viewModel: ObjectiveDetailViewModel
    @State var activeSheet: AmmountsSheet?
    
    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            // TODO: - Tela de loading enquanto nao tem objectiveItemViewModel
            if let objectiveItemViewModel = viewModel.objectiveItemViewModel {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ObjectiveItemView(viewModel: objectiveItemViewModel)
                        .padding()
                    
                    HStack {
                        Button(action: {
                            if let transactions = objectiveItemViewModel.objective.accountsAmmount, transactions.count > 0 {
                                activeSheet = .withdraw
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Text(Strings.withdraw.toLocalizedString)
                                Spacer()
                            }
                            
                        })
                        .padding()
                        .buttonStyle(PrimaryButtonStyle(disabled: true))
                        
                        Button(action: {
                            if let acc = viewModel.filteredAccounts, acc.count > 0 {
                                activeSheet = .add
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Text(Strings.addMoney.toLocalizedString)
                                Spacer()
                            }
                        })
                        .padding()
                        .buttonStyle(PrimaryButtonStyle())
                    }.padding(.vertical)
                    
                    HStack {
                        Text(Strings.history.toLocalizedString)
                            .font(.headline)
                        Spacer()
                    }.padding()
                    
                    // TODO: - Erro de ficar voltando apos cadastrar nova transacao no objetivo (Menos provavel mas pode ser tbm por causa do ForEach em ObjectivesView)
                    // Possivel solucao: criar uma view para o Item, ex: ObjectiveTransactionView
//                    ForEach<Range<Int>, Int, ModifiedContent<ModifiedContent<ModifiedContent<HStack<TupleView<(VStack<TupleView<(Text, Text)>>, Spacer, Text)>>, _PaddingLayout>, Cardify>, _PaddingLayout>> count (4) != its initial count (3). `ForEach(_:content:)` should only be used for *constant* data. Instead conform data to `Identifiable` or use `ForEach(_:id:content:)` and provide an explicit `id`!
                    
                    ForEach(objectiveItemViewModel.sortedTransactions.indices) { index in
                        VStack {
                            HStack {
                                Text(viewModel.bankAccounts?[objectiveItemViewModel.sortedTransactions[index].accountId]?.name ?? "")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(NumberFormatter.currencyFormatter.string(for: Double(objectiveItemViewModel.sortedTransactions[index].ammount) / 100)!)
                                    .fontWeight(.semibold)
                                    .foregroundColor((Double(objectiveItemViewModel.sortedTransactions[index].ammount) / 100) < 0 ? .negativeRed : .fintechGreen)
                            }
                            HStack{
                                Text(Strings.fromAccount.toLocalizedString)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(DateFormatter.localizedString(from: objectiveItemViewModel.sortedTransactions[index].date, dateStyle: .medium, timeStyle: .none))
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                        .font(.subheadline)
                        .padding()
                        .cardify()
                        .padding([.bottom, .horizontal])
                    }
                }
            }
            }
        }
        // TODO: - Adicionar botao de apagar
        .navigationBarItems(trailing: Button(action: {
            activeSheet = .edit
        }) {
            Image(systemName: "pencil")
                .font(.title)
        })
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                ManageObjectiveAmmountView(viewModel: .init(budgetId: viewModel.budgetId, objective: viewModel.objectiveItemViewModel!.objective, accounts: viewModel.filteredAccounts ?? [], isShowing: .init(get: {
                    self.activeSheet == .add
                }, set: { isShowing in
                    activeSheet = isShowing ? .add : nil
                })))
            case .withdraw:
                ManageObjectiveAmmountView(viewModel: .init(budgetId: viewModel.budgetId, objective: viewModel.objectiveItemViewModel!.objective, accounts: viewModel.accounts ?? [], isShowing: .init(get: {
                    self.activeSheet == .withdraw
                }, set: { isShowing in
                    self.activeSheet = isShowing ? .withdraw : nil
                }), transactionsHistory: viewModel.objectiveItemViewModel!.objective.accountsAmmount))
            case .edit:
                CreateObjectiveView(viewModel: .init(budgetId: viewModel.budgetId, isShowing: .init(get: {
                    self.activeSheet == .edit
                }, set: { isShowing in
                    self.activeSheet = isShowing ? .edit : nil
                }), editObjective: viewModel.objectiveItemViewModel!.objective))
            }
        }
        .navigationBarTitle(viewModel.objectiveItemViewModel?.objective.title ?? "")
    }
}

struct ObjectiveItemView: View {
    @ObservedObject var chartValue = ChartValue()
    @ObservedObject var viewModel: ObjectiveItemViewModel
    var title: String?
    
    var body: some View {
        VStack {
            if let _ = title {
                HStack {
                    Text(viewModel.objective.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                VStack {
                    ProgressCircleView(viewModel: .init(percentageSpent: viewModel.ammountPercentage))
                    VStack {
                        Text(NumberFormatter.currencyFormatter.string(for: viewModel.currentAmmount)!)
                            .fontWeight(.bold)
                        Text("/ \(NumberFormatter.currencyFormatter.string(for: Double(viewModel.objective.targetAmmount) / 100)!)")
                            .font(.caption2)
                    }
                }
                Spacer()
                VStack {
                    ProgressCircleView(viewModel: .init(percentageSpent: viewModel.timePercentage))
                    VStack {
                        Text(Strings.timeLeft.toLocalizedString)
                            .fontWeight(.bold)
                        Text(viewModel.timeLeftString)
                            .font(.caption2)
                    }
                }
                Spacer()
            }.padding()
            
            //TODO: - definir quantidade de dias e valores
            if let _ = title {
                LineChartView(lineChartViewModel: viewModel.lineChartViewModel, themeColor: .fintechGreen, showShadow: true)
                    .frame(height: chartHeight)
                    .environmentObject(chartValue)
                    .cornerRadius(25, corners: [.bottomLeft, .bottomRight])
            } else {
                LineChartView(lineChartViewModel: viewModel.lineChartViewModel, themeColor: .fintechGreen, showShadow: false)
                    .frame(height: chartHeight)
                    .environmentObject(chartValue)
                
                VStack {
                    if chartValue.interactionInProgress {
                        Text(NumberFormatter.currencyFormatter.string(for: chartValue.currentValue)!)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(chartValue.currentLabel)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    } else {
                        Text(NumberFormatter.currencyFormatter.string(for: viewModel.perMonth)!)
                            .font(.headline)
                            .foregroundColor(.fintechGreen)
                        
                        Text("\(Strings.per.toLocalizedString.lowercased()) \(Strings.month.toLocalizedString.lowercased())")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.2)))
            }
        }
    }
    
    // MARK: - Drawing Constants
    
    private let chartHeight: CGFloat = 150.0
}

enum AmmountsSheet: String, Identifiable {
    case add
    case withdraw
    case edit
    
    var id: String {
        rawValue
    }
}
