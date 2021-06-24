//
//  TextFieldCustomStyle.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import SwiftUI

struct TextFieldCustomStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.system(size: 16, weight: .medium))
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

extension View {
    func textFieldStyle() -> some View {
        modifier(TextFieldCustomStyle())
    }
}
