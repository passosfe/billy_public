//
//  AddUserPermissionViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 27/12/20.
//

import SwiftUI

struct AddUserPermissionView: View {
    @ObservedObject var viewModel: AddUserPermissionViewModel
    @State private var isSaveDisabled = true
    @State private var isPermissionsExpanded = false
    
    var userInfo: some View {
        HStack {
            TextField(Strings.emailToAdd.toLocalizedString, text: $viewModel.newUserEmail)
                .validation(viewModel.allUserEmailValidation)
                .textFieldStyle()
                
        }
        .cardify()
        .padding()
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var permissionDropdown: some View {
        VStack {
            HStack {
                Text(Strings.permission.toLocalizedString)
                    .padding(.leading)
                    .font(.headline)
                Spacer()
            }
            DisclosureGroup(viewModel.permissionType.toLocalizedString, isExpanded: $isPermissionsExpanded) {
                ForEach(viewModel.permissions.filter { $0 != viewModel.permissionType }, id: \.self) { permission in
                    HStack {
                        Text(permission.toLocalizedString)
                            .onTapGesture {
                                viewModel.permissionType = permission
                                withAnimation {
                                    isPermissionsExpanded.toggle()
                                }
                            }
                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .padding()
            .cardify()
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                withAnimation {
                    isPermissionsExpanded.toggle()
                }
            }
        }
        .padding([.horizontal, .top])
        .scaleEffect(isPermissionsExpanded ? dropdownScaleEffect : 1)
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
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    userInfo
                        .blur(radius: isPermissionsExpanded ? blurAmmout : 0)
//                    permissionDropdown
                    Spacer()
                    submitButtonContainer
                        .blur(radius: isPermissionsExpanded ? blurAmmout : 0)
                }
                .onReceive(viewModel.allUserEmailValidation) { validation in
                    isSaveDisabled = !validation.isSuccess
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
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
            .navigationBarTitle("\(Strings.add.toLocalizedString) \(Strings.permission.toLocalizedString)")
        }
    }
    
    // MARK: -Drawing Constants
    private let blurAmmout: CGFloat = 5.0
    private let dropdownScaleEffect: CGFloat = 1.05
}


