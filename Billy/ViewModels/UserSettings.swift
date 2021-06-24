//
//  UserSettings.swift
//  Billy
//
//  Created by Felipe Passos on 25/11/20.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var mainBudgetId: String? {
        didSet {
            UserDefaults.standard.set(mainBudgetId, forKey: "mainBudgetId")
        }
    }
    
    init() {
        self.mainBudgetId = UserDefaults.standard.object(forKey: "mainBudgetId") as? String
    }
}
