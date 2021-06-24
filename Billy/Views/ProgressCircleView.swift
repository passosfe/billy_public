//
//  ProgressCircleView.swift
//  Billy
//
//  Created by Felipe Passos on 08/11/20.
//

import SwiftUI

struct ProgressCircleView: View {
    @ObservedObject var viewModel: ProgressCircleViewModel
    @State private var percentage: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: circleMultiplier)
                .stroke(style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .fill(Color.secondary.opacity(backgroundCircleOpacity))
                .rotationEffect(.init(degrees: rotationEffect))
            Circle()
                .trim(from: 0.0, to: percentage)
                .stroke(style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .fill(viewModel.isReachingLimit ? Color.negativeRed : Color.fintechGreen)
                .rotationEffect(.init(degrees: rotationEffect))
            if let icon = viewModel.icon {
                Text(icon)
                    .font(.title)
                    .padding(padding)
            } else {
                Text("\(Int(viewModel.percentageSpent * 100))%")
                    .fontWeight(.bold)
                    .padding(padding)
            }
            
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
                percentage = min(CGFloat(viewModel.percentageSpent), 1) * circleMultiplier
            }
        }
        // TODO
        // FIXME: - Mover grafico ao fazer uma transacao. Abaixo atualiza varias vezes por frame (nao funciona)
        .onChange(of: viewModel.percentageSpent, perform: { value in
            withAnimation(.easeInOut(duration: animationDuration)) {
                percentage = min(CGFloat(viewModel.percentageSpent), 1) * circleMultiplier
            }
        })
    }
    
    // MARK: -Drawing Constants
    private let circleMultiplier: CGFloat = 0.75
    private let rotationEffect: Double = -225
    private let lineWidth: CGFloat = 10
    private let padding: CGFloat = 25
    private let backgroundCircleOpacity: Double = 0.2
    private let animationDuration: Double = 1.0
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView(viewModel: .init(percentageSpent: 0.45, icon: "🍸"))
            .frame(width: 200, height: 200)
            .preferredColorScheme(.light)
    }
}
