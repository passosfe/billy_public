//
//  PieCircleViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 23/12/20.
//

import Foundation

final class PieCircleViewModel: ObservableObject {
    @Published var outerPercentage: Double
    @Published var innerPercentage: Double
    
    init(outerPercentage: Double, innerPercentage: Double) {
        self.outerPercentage = outerPercentage
        self.innerPercentage = innerPercentage
    }
}
