//
//  ProgressBarView.swift
//  Billy
//
//  Created by Felipe Passos on 23/12/20.
//

import SwiftUI

struct ProgressBarView: View {
    @ObservedObject var viewModel: ProgressBarViewModel
    private(set) var leftColor: Color
    private(set) var rightColor: Color
    @State private(set) var leftPercentage: CGFloat = 0
    @State private(set) var rightPercentage: CGFloat = 0
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.secondary.opacity(backgroundCircleOpacity))
                        .frame(width: geometry.size.width, height: 10)
                    
                    HStack {
                        Rectangle()
                            .fill(leftColor)
                            .frame(width: geometry.size.width * leftPercentage, height: 10)
                            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                            .cornerRadius(10, corners: leftPercentage < 1 ? [] : [.topRight, .bottomRight])
                            
                        Spacer(minLength: 0)
                    }
                    
                    HStack {
                        Spacer(minLength: 0)
                        Rectangle()
                            .fill(rightColor)
                            .frame(width: geometry.size.width * rightPercentage, height: 10)
                            .cornerRadius(10, corners: [.topRight, .bottomRight])
                            .cornerRadius(10, corners: rightPercentage < 1 ? [] : [.topLeft, .bottomLeft])
                    }
                   
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    leftPercentage = max(min(CGFloat(viewModel.leftPercentage), 1), 0)
                    rightPercentage = max(min(CGFloat(viewModel.rightPercentage), 1), 0)
                }
            }
            // TODO: - Nao funciona para quando se atualiza os valores
//            .onChange(of: viewModel.leftPercentage, perform: { value in
//                withAnimation(.easeInOut(duration: animationDuration)) {
//                    leftPercentage = max(min(CGFloat(viewModel.leftPercentage), 1), 0)
//                }
//            })
//            .onChange(of: viewModel.rightPercentage, perform: { value in
//                withAnimation(.easeInOut(duration: animationDuration)) {
//                    rightPercentage = max(min(CGFloat(viewModel.rightPercentage), 1), 0)
//                }
//            })
        }
    }
    
    // MARK: -Drawing Constants
    private let rotationEffect: Double = -90
    private let lineWidth: CGFloat = 10
    private let padding: CGFloat = 25
    private let backgroundCircleOpacity: Double = 0.2
    private let animationDuration: Double = 1.0
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(viewModel: .init(rightPercentage: 0.3, leftPercentage: 0.7), leftColor: .fintechGreen, rightColor: .lightPurple)
    }
}
