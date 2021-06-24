//
//  Category.swift
//  Billy
//
//  Created by Felipe Passos on 12/11/20.
//

import Foundation

enum StandardCategory: String, Codable, CaseIterable {
    case bills
    case education
    case amusement
    case fees
    case finance
    case food
    case presents
    case health
    case housing
    case income
    case investiment
    case children
    case personalCare
    case pet
    case shopping
    case taxes
    case travel
    case transport
    
    var icon: String {
        switch self {
        case .bills: return "🧾"
        case .education: return "🎓"
        case .amusement: return "🎢"
        case .fees: return "📉"
        case .finance: return "📈"
        case .food: return "🍸"
        case .presents: return "🎁"
        case .health: return "🩺"
        case .housing: return "🏠"
        case .income: return "💰"
        case .investiment: return "🤑"
        case .children: return "🚸"
        case .personalCare: return "💈"
        case .pet: return "🐾"
        case .shopping: return "🛍"
        case .taxes: return "📝"
        case .travel: return "✈️"
        case .transport: return "⛽️"
        }
    }
    
    var toLocalizedString: String { NSLocalizedString("categories." + rawValue, comment: "") }
}

struct CategoryLimit: Identifiable, Codable {
    let id: String
    let key: String
    let type: CategoryOrigin
    var currentSpent: Int?
    let maxAvailable: Int
    let lastTransactionAt: Date?
}

struct CategoryTransactions: Codable {
    let categoryTransactions: [String: Int]
}

enum CategoryOrigin: String, Codable {
    case standard
}
