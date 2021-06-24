//
//  BillyError.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation

enum BillyError: LocalizedError {
    case auth(description: String)
    case `default`(description: String? = nil)
    
    var errorDescription: String? {
        switch self {
            case let .auth(description):
                return description
            case let .default(description):
                return NSLocalizedString(description ?? "defaultError", comment: "error")
        }
    }
}
