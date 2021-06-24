//
//  ShimmerCardView.swift
//  Billy
//
//  Created by Felipe Passos on 04/12/20.
//

import SwiftUI

struct ShimmerCardView: View {
    @State var show: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    private var primary: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondary: Color {
        colorScheme == .light ? .black : .white
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 15){
                    
                    RoundedRectangle(cornerRadius: iconBackgroundCornerRadius)
                        .fill(primary.opacity(0.09))
                        .frame(width: 55, height: 52)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Rectangle()
                            .fill(primary.opacity(0.09))
                            .frame(width: geometry.size.width * 0.5, height: 15)
                        
                        Rectangle()
                            .fill(primary.opacity(0.09))
                            .frame(width: geometry.size.width * 0.25, height: 15)
                    }
                    
                    Spacer(minLength: 0)
                }
                
                HStack(spacing: 15){
                    
                    RoundedRectangle(cornerRadius: iconBackgroundCornerRadius)
                        .fill(secondary.opacity(0.6))
                        .frame(width: 55, height: 52)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Rectangle()
                            .fill(secondary.opacity(0.6))
                            .frame(width: geometry.size.width * 0.5, height: 15)
                        
                        Rectangle()
                            .fill(secondary.opacity(0.6))
                            .frame(width: geometry.size.width * 0.25, height: 15)
                    }
                    
                    Spacer(minLength: 0)
                }
                .mask(
                    Rectangle()
                        .fill(secondary.opacity(0.6))
                        .rotationEffect(.init(degrees: 70))
                        .offset(x: self.show ? 1000 : -350)
                )
            }
            .padding()
            .onAppear {
                withAnimation(Animation.default.speed(0.15).delay(0).repeatForever(autoreverses: false)){
                    self.show.toggle()
                }
            }
            .cardify()
            .padding()
        }
    }
    
    // MARK: - Drawing Constants
    
    private let iconBackgroundCornerRadius: CGFloat = 20.0
}

struct ShimmerCardView_Previews: PreviewProvider {
    static var previews: some View {
        ShimmerCardView()
    }
}
