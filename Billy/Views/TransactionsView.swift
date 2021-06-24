//
//  TransactionsBoxView.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI

struct TransactionsPageView: View {
    @ObservedObject private(set) var transactionListViewModel: TransactionListViewModel
    @EnvironmentObject var settings: UserSettings
    
    var mainContentView: some View {
        VStack {
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
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    TransactionListView(viewModel: transactionListViewModel)
//                        .padding(.top)
                    if transactionListViewModel.isLoading {
                        ShimmerCardView()
                            .padding(.bottom, 70)
                    }
                }
                .padding(.vertical)
                .padding(.bottom)
            }
            .padding(.top)
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            mainContentView
        }.alert(isPresented: Binding<Bool>.constant($transactionListViewModel.error.wrappedValue != nil), content: { () -> Alert in
        Alert(title: Text("Error!"),
              message: Text($transactionListViewModel.error.wrappedValue?.localizedDescription ?? ""),
              dismissButton: .default(Text("OK"), action: {
                transactionListViewModel.error = nil
              }))
        })
        // TODO: - Sheet aqui por que na TransactionListView da problema
        .sheet(isPresented: $transactionListViewModel.showingEdit) {
            CreateTransactionView(viewModel: .init(budgetId: settings.mainBudgetId!, bankAccounts: transactionListViewModel.bankAccounts!, isShowing: $transactionListViewModel.showingEdit, editTransaction: transactionListViewModel.transactionToEdit!, isTransactionEdited: $transactionListViewModel.isTransactionEdited))
        }
        .navigationBarTitle(Strings.transactions.toLocalizedString)
    }
}

struct TransactionListView: View {
    @ObservedObject private(set) var viewModel: TransactionListViewModel
    @GestureState var isDragging = false
    
    var transactionItems: some View {
        ForEach(viewModel.itemViewModels) { itemViewModel in
            ZStack {
                HStack {
                    Spacer()
                                                    
                    Button(action: {
                        withAnimation {
                            itemViewModel.offset = 0
                        }
                        viewModel.send(action: .deleteTransaction, transactionViewModel: itemViewModel)
                    }) {
                        Image(systemName: "trash")
                            .font(.title)
                            .foregroundColor(.negativeRed)
                            .frame(width: 65)
                            .padding(.vertical)
                    }
                }
                
                if let itemId = viewModel.itemViewModels.last?.id, itemId == itemViewModel.id {
                    GeometryReader { geometry in
                        TransactionItemView(viewModel: itemViewModel)
                            .offset(x: itemViewModel.offset)
                            .gesture(
                                DragGesture()
                                    // FIXME: drag nao funciona
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
                            .onTapGesture {
                                self.viewModel.send(action: .editTransaction, transactionViewModel: itemViewModel)
                            }
                            .onAppear {
                                if geometry.frame(in: .global).maxY < UIScreen.main.bounds.height + 75 {
                                    self.viewModel.send(action: .loadMore, transactionViewModel: itemViewModel)
                                }
                            }
                    }
                } else {
                    TransactionItemView(viewModel: itemViewModel)
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
                        .onTapGesture {
                            self.viewModel.send(action: .editTransaction, transactionViewModel: itemViewModel)
                        }
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    var noItemsToShow: some View {
        Text(Strings.registerFirstTransaction.toLocalizedString)
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.vertical, noItemsVerticalPadding)
            .padding(.horizontal, noItemsHorizontalPadding)
    }
    
    @ViewBuilder
    private func content() -> some View {
        if !viewModel.itemViewModels.isEmpty {
            LazyVStack {
                transactionItems
            }
        } else if !viewModel.isLoading {
            noItemsToShow
        }
    }
    
    var body: some View {
        content()
    }
    
    // MARK: - Drawing Constants
    
    private let noItemsHorizontalPadding: CGFloat = 20.0
    private let noItemsVerticalPadding: CGFloat = 60.0
}

struct TransactionItemView: View {
    private(set) var viewModel: TransactionItemViewModel
    
    var body: some View {
        HStack {
            VStack {
                Text(viewModel.icon)
                    .padding()
            }
            .background(Color.secondary.opacity(iconBackgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: iconBackgroundCornerRadius))
            .padding(.trailing, iconBackgroundHorizontalPadding)
                
            
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .fontWeight(.semibold)
                Text(viewModel.subTitle)
                    .foregroundColor(.secondary)
            }.font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(NumberFormatter.currencyFormatter.string(for: Double(viewModel.transaction.ammount) / 100)!)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.transaction.type == .expense ? .negativeRed : .fintechGreen)
                Text(DateFormatter.localizedString(from: viewModel.transaction.date, dateStyle: .medium, timeStyle: .none))
                    .foregroundColor(.secondary)
            }.font(.subheadline)
        }
        .padding()
        .cardify()
        .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: - Drawing Constants
    
    private let iconBackgroundOpacity: Double = 0.2
    private let iconBackgroundCornerRadius: CGFloat = 20.0
    private let iconBackgroundHorizontalPadding: CGFloat = 5.0
}
