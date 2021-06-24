//
//  RCValues.swift
//  Billy
//
//  Created by Felipe Passos on 31/12/20.
//

import Foundation
import Firebase

class RCValues {
    static let sharedInstance = RCValues()

    private init(remoteConfigService: RemoteConfigServiceProtocol = RemoteConfigService()) {
        loadDefaultValues()
        let _ = remoteConfigService.fetchValues()
    }

    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            ValueKey.maxCategoryLimits.rawValue : 5,
            ValueKey.maxBankAccounts.rawValue : 2,
            ValueKey.maxObjectives.rawValue : 1,
            ValueKey.maxBudgets.rawValue : 1,
            ValueKey.maxUserPerBudget.rawValue : 1
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func ammount(for key: ValueKey) -> Int {
        RemoteConfig.remoteConfig()[key.rawValue].numberValue.intValue
    }
}

enum ValueKey: String {
    case maxCategoryLimits
    case maxBankAccounts
    case maxObjectives
    case maxBudgets
    case maxUserPerBudget
}
