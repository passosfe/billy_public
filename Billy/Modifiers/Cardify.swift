//
//  Cardify.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI

struct Cardify: ViewModifier {
    var shape: CardShape
    var background: Color
   func body(content: Content) -> some View {
        ZStack {
            switch shape {
            case .circle:
                Circle()
                    .fill(background)
                    .shadow(color: Color.black.opacity(opacity), radius: radius, x: x, y: y)
            case .rectangle:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(background)
                    .shadow(color: Color.black.opacity(opacity), radius: radius, x: x, y: y)
            }
            
            content
        }
   }
    
    // MARK: -Drawing Constants
    
    private let cornerRadius: CGFloat = 25.0
    private let opacity: Double = 0.1
    private let radius: CGFloat = 10.0
    private let x: CGFloat = 0
    private let y: CGFloat = 0
}

extension View {
    func cardify(with shape: CardShape = .rectangle, background: Color = .cardBackground) -> some View {
        modifier(Cardify(shape: shape, background: background))
    }
}

enum CardShape {
    case circle
    case rectangle
}
