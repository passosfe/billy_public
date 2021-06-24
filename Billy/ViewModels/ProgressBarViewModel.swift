//
//  ProgressBarViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 23/12/20.
//

import Foundation

final class ProgressBarViewModel: ObservableObject {
    @Published var rightPercentage: Double
    @Published var leftPercentage: Double
    
    init(rightPercentage: Double, leftPercentage: Double) {
        self.rightPercentage = rightPercentage
        self.leftPercentage = leftPercentage
    }
}
