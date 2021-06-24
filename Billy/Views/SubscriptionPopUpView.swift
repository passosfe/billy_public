//
//  SubscriptionPopUpView.swift
//  Billy
//
//  Created by Felipe Passos on 31/12/20.
//

import SwiftUI

struct SubscriptionPopUpView<Content: View>: View {
    @State var activeSheet: SheetType?
    let content: () -> Content
    let actionIfSubscribe: () -> Void
    let dismiss: () -> Void
    
    init(actionIfSubscribe: @escaping () -> Void, dismiss: @escaping () -> Void, content: @escaping () -> Content) {
        self.content = content
        self.actionIfSubscribe = actionIfSubscribe
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(edges: .all)
                    .onTapGesture {
                        dismiss()
                    }
                
                VStack {
                    content()
                        .padding([.top, .horizontal])
                        .padding(.horizontal)
                    Button(action: {
                        activeSheet = .subscribe
                    }, label: {
                        HStack {
                            Text("🏅")
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text(Strings.becomePremium.toLocalizedString)
                                    .font(.headline)
                                Text(Strings.subscribeAndUnlock.toLocalizedString)
                                    .font(.subheadline)
                            }
                        }
                    })
                    .buttonStyle(PrimaryButtonStyle())
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom)
                .background(RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color.popUpBackground))
                .padding()
            }.ignoresSafeArea(edges: .all)
            Spacer()
        }
        .ignoresSafeArea(edges: .all)
        .sheet(item: $activeSheet){ sheet in
            SubscriptionView(viewModel: .init(isShowing: .init(get: {
                self.activeSheet == .subscribe
            }, set: { isShowing in
                activeSheet = isShowing ? .subscribe : nil
                actionIfSubscribe()
            })))
        }
    }
    
    enum SheetType: String, Identifiable {
        case subscribe
        
        var id: String {
            rawValue
        }
    }
}

struct SubscriptionPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .all)
            VStack {
                Text("")
                    .foregroundColor(.black)
                Spacer()
            }
            SubscriptionPopUpView(actionIfSubscribe: {
                print("")
            }, dismiss: {
                print("")
            }) {
                Text("")
            }
        }
        
    }
}
