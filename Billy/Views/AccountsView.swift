//
//  AccountsView.swift
//  Billy
//
//  Created by Felipe Passos on 22/12/20.
//

import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var viewModel: AccountsViewModel
    @Binding var showSubscriptionPopUp: Bool
    @State var activeSheet: AccountSheet?
    @GestureState var isDragging = false
    
    var accounts: some View {
        VStack {
            HStack {
                Text(Strings.bankAccounts.toLocalizedString)
                    .fontWeight(.bold)
                Spacer()
            }.padding(.bottom)
            
            LazyVStack {
                ForEach(viewModel.accountItemsViewModels) { itemViewModel in
                    ZStack {
                        HStack {
                            Spacer()
                                                            
                            Button(action: {
                                withAnimation {
                                    itemViewModel.offset = 0
                                }
                                viewModel.send(action: .delete, itemViewModel: itemViewModel)
                            }) {
                                Image(systemName: "trash")
                                    .font(.title)
                                    .foregroundColor(.negativeRed)
                                    .frame(width: 65)
                                    .padding(.vertical)
                            }
                        }
                        NavigationLink(
                            destination: NavigationLazyView(AccountDetailView(viewModel: .init(account: itemViewModel.account), transactionListViewModel: .init(budgetId:  viewModel.budgetId, isInfiniteScroll: true, filterAccountId: itemViewModel.account.id))),
                            label: {
                                AccountItemView(viewModel: itemViewModel)
                                    .offset(x: itemViewModel.offset)
                                    .gesture(
                                        DragGesture()
                                            .updating($isDragging, body: { (value, state, _) in
                                                state = true
                                                if value.translation.width < 0 && isDragging{
                                                    itemViewModel.offset = value.translation.width
                                                }
                                            }).onEnded({ (value) in
                                                withAnimation{
                                                    if -value.translation.width >= 50{
                                                        itemViewModel.offset = -65
                                                    }
                                                    else{
                                                        itemViewModel.offset = 0
                                                    }
                                                }
                                    }))
                            }).buttonStyle(NavigationButtonStyle())
                    }
                }
            }
        }.padding()
    }
    
    var balanceContainer: some View {
        LazyVStack {
            VStack {
                PieCircleView(viewModel: .init(outerPercentage: viewModel.frozenBalancePercentage, innerPercentage: viewModel.freeBalancePercentage), innerColor: .lightPurple, outerColor: .fintechGreen) {
                    VStack {
                        Text(viewModel.totalBalance)
                            .font(viewModel.totalBalanceLabelFont)
                            .fontWeight(.bold)
                            .foregroundColor(.fintechGreen)
                        Text(Strings.totalBalance.toLocalizedString)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
            }
            
            HStack {
                VStack {
                    Text(NumberFormatter.currencyFormatter.string(for: viewModel.totalFreeBalance)!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.lightPurple)
                    Text(Strings.available.toLocalizedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                VStack {
                    Text(NumberFormatter.currencyFormatter.string(for: viewModel.totalFrozenBalance)!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.fintechGreen)
                    Text(Strings.frozen.toLocalizedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .cardify()
            .fixedSize()
            .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                balanceContainer
                accounts
            }
            .navigationBarItems(trailing: Button(action: {
                viewModel.send(action: .create)
            }) {
                Image(systemName: "plus")
                    .font(.title)
            })
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Strings.accounts.toLocalizedString)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $viewModel.showingActionSheet) {
            ActionSheet(title: Text(Strings.create.toLocalizedString), message: Text(Strings.selectToCreate.toLocalizedString), buttons: [
                .default(Text(Strings.account.toLocalizedString)) {
                    viewModel.insideLimit(for: .maxBankAccounts, value: viewModel.accountItemsViewModels.count, ifInside: {
                        self.activeSheet = .bankAccount
                    }, ifOutside: {
                        showSubscriptionPopUp = true
                    })
                },
//                .default(Text("Cartão de crédito")) { self.activeSheet = .creditCard },
                .cancel()
            ])
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .bankAccount:
                CreateBankAccountView(viewModel: .init(budgetId: settings.mainBudgetId!, isShowing: .init(get: {
                    self.activeSheet == .bankAccount
                }, set: { isShowing in
                    activeSheet = isShowing ? .bankAccount : nil
                })))
//            case .creditCard:
//                Text("Cartao")
            }
        }
        .alert(isPresented: $viewModel.minimumAccountError, content: { () -> Alert in
            Alert(title: Text(Strings.ops.toLocalizedString),
                  message: Text(Strings.atLeastOneAccount.toLocalizedString),
                  dismissButton: .cancel({
                    viewModel.minimumAccountError = false
                  }))
        })
    }
    
    struct NavigationButtonStyle: ButtonStyle {
        public func makeBody(configuration: NavigationButtonStyle.Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 1 : 1)
        }
    }
}

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    @ObservedObject var transactionListViewModel: TransactionListViewModel
    
    var balanceContainer: some View {
        LazyVStack {
            PieCircleView(viewModel: .init(outerPercentage: viewModel.frozenBalancePercentage, innerPercentage: viewModel.freeBalancePercentage), innerColor: .lightPurple, outerColor: .fintechGreen) {
                VStack {
                    Text(viewModel.totalBalance)
                        .font(viewModel.totalBalanceLabelFont)
                        .fontWeight(.bold)
                        .foregroundColor(.fintechGreen)
                    Text(Strings.totalBalance.toLocalizedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200, height: 200)
            
            HStack {
                VStack {
                    Text(NumberFormatter.currencyFormatter.string(for: viewModel.totalFreeBalance)!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.lightPurple)
                    Text(Strings.available.toLocalizedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                VStack {
                    Text(NumberFormatter.currencyFormatter.string(for: viewModel.totalFrozenBalance)!)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.fintechGreen)
                    Text(Strings.frozen.toLocalizedString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .cardify()
            .fixedSize()
            .padding()
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            balanceContainer
            HStack {
                Text(Strings.transactions.toLocalizedString)
                    .fontWeight(.bold)
                Spacer()
            }.padding(.horizontal)
            LazyVStack {
                HStack {
                    Button(action: {
                        transactionListViewModel.send(action: .prevMonth)
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(transactionListViewModel.dateLabel)
                    Spacer()
                    Button(action: {
                        transactionListViewModel.send(action: .nextMonth)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding([.top, .horizontal])
                // TODO: - Usar datepicker pra ficar mais bonito e funcional
    //            DatePicker("", selection: $transactionListViewModel.date, displayedComponents: .date)
    //                .labelsHidden()
                LazyVStack {
                    TransactionListView(viewModel: transactionListViewModel)
//                        .padding(.top)
                    if transactionListViewModel.isLoading {
                        ShimmerCardView()
                            .padding(.bottom, 70)
                    }
                }
                .padding([.vertical, .bottom])
            }.padding(.top)
        }
        // TODO: - Editar e excluir conta
//        .navigationBarItems(trailing: Button(action: {
//                print("edit")
//            }) {
//                Image(systemName: "pencil")
//                    .font(.title)
//            })
        .navigationBarTitle(viewModel.account.name)
    }
}

struct AccountItemView: View {
    @ObservedObject var viewModel: AccountItemViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.account.name)
                    .font(.headline)
                Spacer()
                Text(NumberFormatter.currencyFormatter.string(for: viewModel.currentAmmount)!)
                    .foregroundColor(viewModel.currentAmmount > 0 ? .fintechGreen : .negativeRed)
                    .font(.headline)
            }
            
            HStack {
                Text(viewModel.account.type.toLocalizedString)
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
                Text(Strings.total.toLocalizedString)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            ProgressBarView(viewModel: .init(rightPercentage: viewModel.currentAmmount == 0 ? 0.5 : viewModel.rightPercentage, leftPercentage: viewModel.currentAmmount == 0 ? 0.5 : viewModel.leftPercentage), leftColor: .lightPurple, rightColor: .fintechGreen)
        }
        .padding()
        .cardify()
    }
}

enum AccountSheet: String, Identifiable {
//    case creditCard
    case bankAccount
    
    var id: String {
        rawValue
    }
}
