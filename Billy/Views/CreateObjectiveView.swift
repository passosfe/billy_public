//
//  CreateObjectiveView.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import SwiftUI

struct CreateObjectiveView: View {
    @ObservedObject var viewModel: CreateObjectiveViewModel
    @State private var isSaveDisabled = true
    @State private var showNumberPad = true
    
    var ammount: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NumberFormatter.currencyFormatter.string(for: viewModel.targetAmmountValue)!)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.showNumberPad = true
                    }
                }
                .font(Font.system(size: 50, weight: .light))
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .foregroundColor(.fintechGreen)
        }
        .padding()
    }
    
    var objectiveInfo: some View {
        VStack {
            HStack(spacing: 0) {
                Image(systemName: "building.columns")
                    .padding(.leading)
                    .frame(width: 50)
                
                TextField(Strings.formTitle.toLocalizedString, text: $viewModel.title, onEditingChanged: { (editingChanged) in
                    if editingChanged, showNumberPad {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            showNumberPad.toggle()
                        }
                    }
                })
                .validation(viewModel.titleValidation)
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
                    
                    TextEditor(text: $viewModel.description)
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                                if showNumberPad {
                                    withAnimation(.easeInOut(duration: 0.7)) {
                                        showNumberPad.toggle()
                                    }
                                }
                            }
                        .textFieldStyle()
                        .padding(.trailing)
                }
            }.frame(height: UIScreen.main.bounds.height * 0.3)
            
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.625)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var datePicker: some View {
        HStack {
            Spacer()
            DatePicker("", selection: $viewModel.dateLimit, in: Date()..., displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
        }
    }
    
    var submitButtonContainer: some View {
        VStack {
            Button(action: {
                viewModel.send(action: .saveObjective)
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
                VStack(alignment: .leading, spacing: 0) {
                    datePicker
                    Spacer()
                    ammount
                        .padding(.bottom, (UIScreen.main.bounds.height * 0.625) - 35)
                }
            }
            objectiveInfo
            
            NumberPadView(show: self.$showNumberPad, txt: Binding<String>(
                get: { () -> String in
                    return NumberFormatter.currencyFormatter.string(for: viewModel.targetAmmountValue)!
                }) { (s) in
                    var s = s
                    s.removeAll { (c) -> Bool in
                        !c.isNumber
                    }
                viewModel.targetAmmount = s
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
    }
}
