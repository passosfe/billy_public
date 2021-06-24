//
//  CreateTransactionView.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI

struct CreateBankAccountView: View {
    @ObservedObject var viewModel: CreateBankAccountViewModel
    @State private var isSaveDisabled = true
    @State private var isTypeExpanded = false
    @State private var showNumberPad = true
    
    var balance: some View {
        HStack(spacing: 0) {
            Image(systemName: viewModel.isNegativeBalance ? "minus" : "plus")
                .frame(width: negativeBalanceButtonSize, height: negativeBalanceButtonSize)
                .padding()
                .cardify(with: .circle)
                .fixedSize()
                .onTapGesture {
                    viewModel.isNegativeBalance.toggle()
                }
            
            Text(NumberFormatter.currencyFormatter.string(for: viewModel.accountBalanceValue)!)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.showNumberPad = true
                        if isTypeExpanded {
                            isTypeExpanded.toggle()
                        }
                    }
                }
                .font(Font.system(size: 50, weight: .light))
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .foregroundColor(viewModel.isNegativeBalance ? .negativeRed : .fintechGreen)
            
            Spacer()
        }
        .padding()
    }
    
    var accountTypeDropdown: some View {
        VStack {
            if isTypeExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.accountTypes, id: \.self) { value in
                        HStack {
                            Image(systemName: "pencil")
                                .padding(.leading)
                                .frame(width: 50)
                            Text(value.toLocalizedString)
                                .font(.title3)
                                .bold()
                                .tag(value)
                            Spacer()
                        }
                        .foregroundColor(.fintechGreen)
                        .padding(.vertical)
                        .contentShape(Rectangle())
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                        .onTapGesture {
                            viewModel.accountType = value
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isTypeExpanded.toggle()
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Image(systemName: "pencil")
                        .padding(.leading)
                        .frame(width: 50)
                    Text(viewModel.accountType.toLocalizedString)
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
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.75)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var accountInfo: some View {
        VStack {
            HStack(spacing: 0) {
                Image(systemName: "building.columns")
                    .padding(.leading)
                    .frame(width: 50)
                
                TextField(Strings.alias.toLocalizedString, text: $viewModel.accountName)
                    .validation(viewModel.accountNameValidation)
                    .textFieldStyle()
                    .padding(.trailing)
            }.frame(height: UIScreen.main.bounds.height * 0.125)
            
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: "pencil")
                    .padding(.leading)
                    .frame(width: 50)
                
                VStack(alignment: .leading) {
                    Text(Strings.description.toLocalizedString)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                    
                    TextEditor(text: $viewModel.accountDescription)
                        .textFieldStyle()
                        .padding(.trailing)
                }
            }.frame(height: UIScreen.main.bounds.height * 0.3)
            
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground2)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.625)
        .offset(y: isTypeExpanded ? UIScreen.main.bounds.height - 40 : (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var submitButtonContainer: some View {
        VStack {
            Button(action: {
                viewModel.send(action: .createBankAccount)
            }, label: {
                HStack {
                    Spacer(minLength: 0)
                    Text(isSaveDisabled ? Strings.fillAllFields.toLocalizedString : Strings.create.toLocalizedString)
                    Spacer(minLength: 0)
                }
            })
            .buttonStyle(PrimaryButtonStyle(disabled: isSaveDisabled))
            .disabled(isSaveDisabled)
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
                VStack {
                    Spacer()
                    balance
                        .padding(.bottom, (UIScreen.main.bounds.height * 0.75) - 35)
                }
            }
            accountTypeDropdown
            accountInfo
            
            NumberPadView(show: self.$showNumberPad, txt: Binding<String>(
                get: { () -> String in
                    return NumberFormatter.currencyFormatter.string(for: viewModel.accountBalanceValue)!
                }) { (s) in
                    var s = s
                    s.removeAll { (c) -> Bool in
                        !c.isNumber
                    }
                viewModel.accountBalance = s
            })
            .offset(y: self.showNumberPad ? (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! - 40 : UIScreen.main.bounds.height - 40)
            
            submitButtonContainer
        }
        .onReceive(viewModel.allValidation) { validation in
            isSaveDisabled = !validation.isSuccess
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
        .background(Color.appBackground.edgesIgnoringSafeArea(.all)).dismissKeyboardOnTap()
        .accentColor(.fintechGreen)
    }
    
    // MARK: -Drawing Constants
    private let negativeBalanceButtonSize: CGFloat = 15.0
}

struct CreateBankAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateBankAccountView(viewModel: .init(budgetId: "", isShowing: .constant(true)))
    }
}
