//
//  OnboardingItem.swift
//  Billy
//
//  Created by Felipe Passos on 11/11/20.
//

import Foundation

struct OnboardingItem: Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var description: String
}
