//
//  PieCircleView.swift
//  Billy
//
//  Created by Felipe Passos on 23/12/20.
//

import SwiftUI

struct PieCircleView<Content: View>: View {
    @ObservedObject var viewModel: PieCircleViewModel
    private let innerColor: Color
    private let outerColor: Color
    @State private var outerPercentage: CGFloat = 0
    @State private var innerPercentage: CGFloat = 0
    private let content: Content
    
    init(viewModel: PieCircleViewModel, innerColor: Color, outerColor: Color, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = viewModel
        self.innerColor = innerColor
        self.outerColor = outerColor
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(style: .init(lineWidth: lineWidth))
                    .fill(Color.secondary.opacity(backgroundCircleOpacity))
                Circle()
                    .trim(from: 0.0, to: outerPercentage)
                    .stroke(style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .fill(outerColor)
                    .rotationEffect(.init(degrees: rotationEffect))
            }
            
            ZStack {
                Circle()
                    .stroke(style: .init(lineWidth: lineWidth))
                    .fill(Color.secondary.opacity(backgroundCircleOpacity))
                Circle()
                    .trim(from: 0.0, to: innerPercentage)
                    .stroke(style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .fill(innerColor)
                    .rotationEffect(.init(degrees: rotationEffect))
            }.padding()
            
            content
                .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
                outerPercentage = min(CGFloat(viewModel.outerPercentage), 1)
                innerPercentage = min(CGFloat(viewModel.innerPercentage), 1)
            }
        }
        // TODO: - Nao funciona para quando se atualiza os valores
//        .onChange(of: viewModel.outerPercentage, perform: { value in
//            withAnimation(.easeInOut(duration: animationDuration)) {
//                outerPercentage = min(CGFloat(viewModel.outerPercentage), 1)
//            }
//        })
//        .onChange(of: viewModel.innerPercentage, perform: { value in
//            withAnimation(.easeInOut(duration: animationDuration)) {
//                innerPercentage = min(CGFloat(viewModel.innerPercentage), 1)
//            }
//        })
    }
    
    // MARK: -Drawing Constants
    private let rotationEffect: Double = -90
    private let lineWidth: CGFloat = 10
    private let padding: CGFloat = 25
    private let backgroundCircleOpacity: Double = 0.2
    private let animationDuration: Double = 1.0
}

struct PieCircleView_Previews: PreviewProvider {
    static var previews: some View {
        PieCircleView(viewModel: .init(outerPercentage: 0.45, innerPercentage: 0.55), innerColor: .lightPurple, outerColor: .fintechGreen) {
            Text("R$ 500,00")
        }
        .frame(width: 200, height: 200)
        .preferredColorScheme(.light)
    }
}
