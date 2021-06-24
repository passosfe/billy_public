//
//  Account.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import FirebaseFirestoreSwift

struct Account: Codable, Identifiable, Equatable {
    let id: String
    let type: AccountType
    let name: String
    let freeBalance: Int
    let description: String
    let frozenBalance: Int?
    let closingDate: Date?
    let dueDate: Date?
    let limit: Int?
    
    init(id: String, type: AccountType, name: String, freeBalance: Int, description: String, frozenBalance: Int) {
        self.id = id
        self.type = type
        self.name = name
        self.freeBalance = freeBalance
        self.description = description
        self.frozenBalance = frozenBalance
        self.closingDate = nil
        self.dueDate = nil
        self.limit = nil
    }
    
    init(id: String, type: AccountType, name: String, freeBalance: Int, description: String, closingDate: Date, dueDate: Date, limit: Int) {
        self.id = id
        self.type = type
        self.name = name
        self.freeBalance = freeBalance
        self.description = description
        self.frozenBalance = nil
        self.closingDate = closingDate
        self.dueDate = dueDate
        self.limit = limit
    }
}

enum AccountType: String, Codable, CaseIterable {
    case checking
    case savings
    case investments
    case creditCard
    
    var icon: String {
        switch self {
        case .checking: return "🏦"
        case .savings: return "💰"
        case .investments: return "📈"
        case .creditCard: return "💳"
        }
    }
    
    var toLocalizedString: String { NSLocalizedString(rawValue, comment: "") }
}
