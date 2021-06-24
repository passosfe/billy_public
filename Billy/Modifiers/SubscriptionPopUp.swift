//
//  SubscriptionPopUp.swift
//  Billy
//
//  Created by Felipe Passos on 31/12/20.
//

import SwiftUI

struct SubscriptionPopUp: ViewModifier {
    var isShowing: Bool = false
    let actionIfSubscribe: () -> Void
    let dismiss: () -> Void
    
    init(show: Bool, actionIfSubscribe: @escaping () -> Void, dismiss: @escaping () -> Void) {
        self.isShowing = show
        self.actionIfSubscribe = actionIfSubscribe
        self.dismiss = dismiss
    }
    
   func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                SubscriptionPopUpView(actionIfSubscribe: actionIfSubscribe, dismiss: dismiss) {
                    VStack {
                        Text(Strings.subscription.toLocalizedString)
                            .font(.headline)
                            .padding(.bottom)
                        Text(Strings.reachedLimit.toLocalizedString)
                            .font(.subheadline)
                    }
                }
            }
        }
   }
}

extension View {
    func subscriptionPupUp(show: Bool, actionIfSubscribe: @escaping () -> Void, dismiss: @escaping () -> Void) -> some View {
        modifier(SubscriptionPopUp(show: show, actionIfSubscribe: actionIfSubscribe, dismiss: dismiss))
    }
}
