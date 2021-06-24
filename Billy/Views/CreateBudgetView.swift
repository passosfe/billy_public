//
//  CreateBudgetView.swift
//  Billy
//
//  Created by Felipe Passos on 18/12/20.
//

import SwiftUI

struct CreateBudgetView: View {
    @ObservedObject var viewModel: CreateBudgetViewModel
    @State private var isSaveDisabled = true
    
    var budgetInfo: some View {
        HStack {
            VStack(spacing: 0) {
                Image(systemName: "building.columns")
                    .padding(.leading)
                    .frame(maxHeight: .infinity)
            }
            
            VStack(spacing: 0) {
                
                TextField(Strings.formTitle.toLocalizedString, text: $viewModel.title)
                    .validation(viewModel.titleValidation)
                    .textFieldStyle()
            }
        }
        .cardify()
        .padding()
    }
    
    var submitButtonContainer: some View {
        Button(action: {
            viewModel.send(action: .create)
        }, label: {
            Text(isSaveDisabled ? Strings.fillAllFields.toLocalizedString : viewModel.buttonText)
                .padding(.horizontal)
        })
        .padding()
        .disabled(isSaveDisabled)
        .buttonStyle(PrimaryButtonStyle(disabled: isSaveDisabled))
    }
    
    var mainContentView: some View {
        ScrollView {
            VStack {
                budgetInfo
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
            .navigationBarTitle("\(viewModel.actionTypeText) \(Strings.budget.toLocalizedString.lowercased())")
        }
    }
}

