//
//  ProgressCircleViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 08/11/20.
//

import Foundation

final class ProgressCircleViewModel: ObservableObject {
    @Published var percentageSpent: Double
    let icon: String?
    var isReachingLimit: Bool {
        if let _ = icon {
            return percentageSpent >= 0.8
        } else {
            return false
        }
    }
    var isBeyondLimit: Bool {
        percentageSpent > 1
    }
    
    init(percentageSpent: Double, icon: String? = nil) {
        self.icon = icon
        self.percentageSpent = percentageSpent
    }
}
