//
//  CreateTransactionView.swift
//  Billy
//
//  Created by Felipe Passos on 25/11/20.
//

import SwiftUI

struct CreateTransactionView: View {
    @ObservedObject var viewModel: CreateTransactionViewModel
    @State private var isTypeExpanded = false
    @State private var isFromAccountExpanded = false
    @State private var isToAccountExpanded = false
    @State private var isCategoriesExpanded = false
    @State private var showNumberPad = true
    
    var ammount: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NumberFormatter.currencyFormatter.string(for: viewModel.transactionValue)!)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.showNumberPad = true
                        if isTypeExpanded {
                            isTypeExpanded.toggle()
                        }
                        if isFromAccountExpanded {
                            isFromAccountExpanded.toggle()
                        }
                        if isToAccountExpanded {
                            isToAccountExpanded.toggle()
                        }
                        if isCategoriesExpanded {
                            isCategoriesExpanded.toggle()
                        }
                    }
                }
                .font(Font.system(size: 50, weight: .light))
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .foregroundColor(viewModel.transactionType == .expense ? .negativeRed : .fintechGreen)
        }
        .padding()
    }
    
    var transactionTypeDropdown: some View {
        VStack {
            if isTypeExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.transactionTypes.filter { $0 != .transfer || viewModel.bankAccounts.count > 1}, id: \.self) { value in
                        HStack {
                            Image(systemName: value.icon)
                                .padding(.leading)
                                .frame(width: 50)
                            Text(value.toLocalizedString)
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .foregroundColor(.fintechGreen)
                        .padding(.vertical)
                        .contentShape(Rectangle())
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                        .onTapGesture {
                            viewModel.transactionType = value
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isTypeExpanded.toggle()
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Image(systemName: viewModel.transactionType.icon)
                        .padding(.leading)
                        .frame(width: 50)
                    Text(viewModel.transactionType.toLocalizedString)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .foregroundColor(.fintechGreen)
                .padding(.vertical)
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isTypeExpanded.toggle()
                        if showNumberPad {
                            showNumberPad.toggle()
                        }
                        if isFromAccountExpanded {
                            isFromAccountExpanded.toggle()
                        }
                        if isToAccountExpanded {
                            isToAccountExpanded.toggle()
                        }
                        if isCategoriesExpanded {
                            isCategoriesExpanded.toggle()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.75)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
        .disabled(viewModel.actionTypeText == Strings.editAction.toLocalizedString ? true : false)
        .onChange(of: viewModel.transactionType) { value in
            if value == .transfer {
                viewModel.category = nil
                viewModel.toAccount = viewModel.bankAccounts.first { $0.id != viewModel.fromAccount.id }
            } else {
                viewModel.toAccount = nil
            }
            if value == .expense {
                viewModel.category = .bills
            }
            if value == .income {
                viewModel.category = .income
            }
        }
    }
    
    var fromAccountDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isFromAccountExpanded {
                Text(Strings.fromAccount.toLocalizedString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding([.leading, .top])
                    .padding(.top)
                    .foregroundColor(.secondary)
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.bankAccounts) { bankAccount in
                        HStack {
                            Image(systemName: "building.columns")
                                .padding(.leading)
                                .frame(width: 50)
                            Text(bankAccount.name)
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .tag(bankAccount.id)
                        .foregroundColor(.fintechGreen)
                        .padding(.vertical)
                        .contentShape(Rectangle())
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                        .onTapGesture {
                            viewModel.fromAccount = bankAccount
                            withAnimation {
                                isFromAccountExpanded.toggle()
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.fromAccount.toLocalizedString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding([.leading, .bottom])
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "building.columns")
                            .padding(.leading)
                            .frame(width: 50)
                        Text(viewModel.fromAccount.name)
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                }
                .foregroundColor(.fintechGreen)
                .padding(.vertical)
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isFromAccountExpanded.toggle()
                        if showNumberPad {
                            showNumberPad.toggle()
                        }
                        if isToAccountExpanded {
                            isToAccountExpanded.toggle()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: viewModel.transactionType == .transfer ? .clearerCardBackground2 : .clearerCardBackground3)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * (viewModel.transactionType == .transfer ? 0.625 : 0.5))
        .offset(y: isTypeExpanded || isCategoriesExpanded ? UIScreen.main.bounds.height - 40 : (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
        .onChange(of: viewModel.fromAccount) { value in
            if viewModel.transactionType == .transfer {
                viewModel.toAccount = viewModel.bankAccounts.first { $0.id != viewModel.fromAccount.id }
            }
        }
        
    }
    
    var toAccountDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isToAccountExpanded {
                Text(Strings.toAccount.toLocalizedString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding([.leading, .top])
                    .padding(.top)
                    .foregroundColor(.secondary)
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.bankAccounts.filter { $0.id != viewModel.fromAccount.id }) { bankAccount in
                        HStack {
                            Image(systemName: "building.columns")
                                .padding(.leading)
                                .frame(width: 50)
                            Text(bankAccount.name)
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .tag(bankAccount.id)
                        .foregroundColor(.fintechGreen)
                        .padding(.vertical)
                        .contentShape(Rectangle())
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                        .onTapGesture {
                            viewModel.toAccount = bankAccount
                            withAnimation {
                                isToAccountExpanded.toggle()
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.toAccount.toLocalizedString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding([.leading, .bottom])
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "building.columns")
                            .padding(.leading)
                            .frame(width: 50)
                        Text(viewModel.toAccount?.name ?? "")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                }
                .foregroundColor(.fintechGreen)
                .padding(.vertical)
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isToAccountExpanded.toggle()
                        if showNumberPad {
                            showNumberPad.toggle()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground3)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
        .offset(y: isTypeExpanded || isFromAccountExpanded ? UIScreen.main.bounds.height - 40 : (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var categoriesDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isCategoriesExpanded {
                Text(Strings.category.toLocalizedString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding([.leading, .top])
                    .padding(.top)
                    .foregroundColor(.secondary)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(viewModel.transactionType.categoriesRelated, id: \.self) { categoryType in
                            VStack {
                                Text(categoryType.icon)
                                Text(categoryType.toLocalizedString)
                                    .font(.footnote)
                                    .bold()
                            }
                            .foregroundColor(.fintechGreen)
                            .padding(.vertical)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.category = categoryType
                                withAnimation {
                                    isCategoriesExpanded.toggle()
                                }
                            }
                        }
                    }.padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.category.toLocalizedString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding([.leading, .bottom])
                        .foregroundColor(.secondary)
                    HStack {
                        Text(viewModel.category?.icon ?? StandardCategory.bills.icon)
                            .padding(.leading)
                            .frame(width: 50)
                        Text(viewModel.category?.toLocalizedString ?? StandardCategory.bills.toLocalizedString)
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                }
                .foregroundColor(.fintechGreen)
                .padding(.vertical)
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isCategoriesExpanded.toggle()
                        if showNumberPad {
                            showNumberPad.toggle()
                        }
                        if isFromAccountExpanded {
                            isFromAccountExpanded.toggle()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground2)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.625)
        .offset(y: isTypeExpanded ? UIScreen.main.bounds.height - 40 : (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var datePicker: some View {
        HStack {
            Spacer()
            DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
        }
    }
    
    var transactionInfo: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: "pencil")
                    .padding(.leading)
                    .frame(width: 50)
            
                VStack(alignment: .leading) {
                    Text(Strings.description.toLocalizedString)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    
                    TextEditor(text: $viewModel.transactionDescription)
                        .textFieldStyle()
                        .padding(.trailing)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.15)
            .padding(.top)
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify()
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.375)
        .offset(y: isTypeExpanded || isFromAccountExpanded || isCategoriesExpanded || isToAccountExpanded ? UIScreen.main.bounds.height - 40 : (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var submitButtonContainer: some View {
        VStack {
            Button(action: {
                viewModel.send(action: .saveTransaction)
            }, label: {
                HStack {
                    Spacer(minLength: 0)
                    Text(viewModel.buttonText)
                    Spacer(minLength: 0)
                }
            })
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxHeight: 40)
            .padding(.vertical)
            .padding(.horizontal)
            .padding(.horizontal)
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify()
        .frame(width: UIScreen.main.bounds.width)
        .fixedSize(horizontal: false, vertical: true)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var mainContentView: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 0) {
                    datePicker
                    Spacer()
                    ammount
                        .padding(.bottom, (UIScreen.main.bounds.height * 0.75) - 35)
                }
            }
            transactionTypeDropdown
            if viewModel.transactionType != .transfer {
                categoriesDropdown
                fromAccountDropdown
            } else {
                fromAccountDropdown
                toAccountDropdown
            }
            transactionInfo
            
            NumberPadView(show: self.$showNumberPad, txt: Binding<String>(
                get: { () -> String in
                    return NumberFormatter.currencyFormatter.string(for: viewModel.transactionValue)!
                }) { (s) in
                    var s = s
                    s.removeAll { (c) -> Bool in
                        !c.isNumber
                    }
                viewModel.transactionAmmount = s
            })
            .offset(y: self.showNumberPad ? (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! - 40 : UIScreen.main.bounds.height - 40)
            
            submitButtonContainer
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ZStack {
                    Color.appBackground.edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            } else {
                mainContentView
            }
        }.alert(isPresented: Binding<Bool>.constant($viewModel.error.wrappedValue != nil), content: { () -> Alert in
            Alert(title: Text("Error!"),
                  message: Text($viewModel.error.wrappedValue?.localizedDescription ?? ""),
                  dismissButton: .default(Text("OK"), action: {
                    viewModel.error = nil
                  }))
        })
        .accentColor(.fintechGreen)
        .background(Color.appBackground.edgesIgnoringSafeArea(.all)).dismissKeyboardOnTap()
    }
}
