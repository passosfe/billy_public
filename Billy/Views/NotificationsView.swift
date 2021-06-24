//
//  NotificationsView.swift
//  Billy
//
//  Created by Felipe Passos on 28/12/20.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel: NotificationViewModel
    // TODO: arrastar para remover??
//    @GestureState var isDragging = false
    
    @ViewBuilder
    func notifications() -> some View {
        if viewModel.newPermissions.count > 0 {
            // TODO: - ver pq e SE fica voltando quando aceita
            ForEach(viewModel.newPermissions.indices) { index in
                VStack {
                    Text("\(viewModel.newPermissions[index].fromEmail) \(Strings.invitedYouTo.toLocalizedString) \(viewModel.newPermissions[index].permissionType.toLocalizedString.lowercased()) \(Strings.theBudget.toLocalizedString) \(viewModel.newPermissions[index].budgetName). \(Strings.doYouAccept.toLocalizedString)")
                        .padding()
                        .font(.body)
                    HStack {
                        Spacer()
                        Button(action: {
                            self.viewModel.send(action: .accept, newPermission: viewModel.newPermissions[index])
                        }, label: {
                            Text(Strings.accept.toLocalizedString)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        })
                        Spacer()
                        Button(action: {
                            self.viewModel.send(action: .reject, newPermission: viewModel.newPermissions[index])
                        }, label: {
                            Text(Strings.reject.toLocalizedString)
                                .foregroundColor(.negativeRed)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        })
                        Spacer()
                    }
                }
                .padding(.bottom)
                .cardify()
                .padding()
            }
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    notifications()
                }.padding()
            }
        }
        .navigationBarTitle(Strings.notifications.toLocalizedString)
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: Binding<Bool>.constant($viewModel.error.wrappedValue != nil), content: { () -> Alert in
            Alert(title: Text("Error!"),
                  message: Text($viewModel.error.wrappedValue?.localizedDescription ?? ""),
                  dismissButton: .default(Text("OK"), action: {
                    viewModel.error = nil
                  }))
        })
        .accentColor(.fintechGreen)
    }
}
