//
//  ManageObjectiveAmmountView.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import SwiftUI

struct ManageObjectiveAmmountView: View {
    @ObservedObject var viewModel: ManageObjectiveAmmountViewModel
    @State private var isSaveDisabled = true
    @State private var isFromAccountExpanded = false
    
    var ammount: some View {
        let binding = Binding<String>(
            get: { () -> String in
                return NumberFormatter.currencyFormatter.string(for: viewModel.ammountValue) ?? "0.00"
            }) { (s) in
                var s = s
                s.removeAll { (c) -> Bool in
                    !c.isNumber
                }
            viewModel.ammount = s
            }
        
        return HStack(spacing: 0) {
            TextField(Strings.formValue.toLocalizedString, text: binding)
                .font(.largeTitle)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .padding(.leading)
                .foregroundColor(.fintechGreen)
                .blur(radius: isFromAccountExpanded ? blurAmmout : 0)
        }
        .padding()
    }
    
    var fromAccountDropdown: some View {
        VStack {
            HStack {
                Text(Strings.fromAccount.toLocalizedString)
                    .padding(.leading)
                Spacer()
            }
            DisclosureGroup("\(viewModel.fromAccount.name)", isExpanded: $isFromAccountExpanded) {
                VStack {
                    ForEach(viewModel.bankAccounts) { bankAccount in
                        HStack {
                            Image(systemName: "building.columns")
                            Text(bankAccount.name)
                                .tag(bankAccount.id)
                                .onTapGesture {
                                    viewModel.fromAccount = bankAccount
                                    withAnimation {
                                        isFromAccountExpanded.toggle()
                                    }
                                }
                            Spacer()
                        }
                        .padding(.top)
                    }
                }
            }
            .padding()
            .cardify()
            .onTapGesture {
                withAnimation {
                    isFromAccountExpanded.toggle()
                }
            }
        }
        .padding([.horizontal, .top])
        .scaleEffect(isFromAccountExpanded ? dropdownScaleEffect : 1)
    }
    
    var submitButtonContainer: some View {
        Button(action: {
            viewModel.send(action: .insertTransaction)
        }, label: {
            Text(isSaveDisabled ? Strings.fillAllFields.toLocalizedString : viewModel.buttonText)
                .padding(.horizontal)
        })
        .padding()
        .disabled(isSaveDisabled)
        .buttonStyle(PrimaryButtonStyle(disabled: isSaveDisabled))
    }
    
    var availableAmmount: some View {
        VStack {
            Text(Strings.available.toLocalizedString)
                .fontWeight(.bold)
            Spacer()
            Text(NumberFormatter.currencyFormatter.string(for: viewModel.maxAvailable)!)
        }.padding([.top, .horizontal])
    }
    
    var mainContentView: some View {
        ScrollView {
            VStack {
                ammount
                fromAccountDropdown
                availableAmmount
                Spacer()
                    .frame(maxHeight: .infinity)
                submitButtonContainer
            }
            .onReceive(viewModel.allValidation) { validation in
                isSaveDisabled = !validation.isSuccess
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ZStack {
                        Color.appBackground.edgesIgnoringSafeArea(.all)
                        ProgressView()
                    }
                } else {
                    mainContentView
                }
            }
            .alert(isPresented: Binding<Bool>.constant($viewModel.error.wrappedValue != nil), content: { () -> Alert in
                Alert(title: Text("Error!"),
                      message: Text($viewModel.error.wrappedValue?.localizedDescription ?? ""),
                      dismissButton: .default(Text("OK"), action: {
                        viewModel.error = nil
                      }))
            })
            .accentColor(.fintechGreen)
            .background(Color.appBackground.edgesIgnoringSafeArea(.all)).dismissKeyboardOnTap()
            .navigationBarTitle("\(viewModel.actionTypeText)")
        }
    }
    
    // MARK: -Drawing Constants
    private let blurAmmout: CGFloat = 5.0
    private let dropdownScaleEffect: CGFloat = 1.05
}
