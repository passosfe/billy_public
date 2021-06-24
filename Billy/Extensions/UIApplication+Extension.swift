//
//  UIApplication+Extension.swift
//  Billy
//
//  Created by Felipe Passos on 04/01/21.
//

import Foundation
import SwiftUI

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}
