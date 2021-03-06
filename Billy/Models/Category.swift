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
        case .bills: return "๐งพ"
        case .education: return "๐"
        case .amusement: return "๐ข"
        case .fees: return "๐"
        case .finance: return "๐"
        case .food: return "๐ธ"
        case .presents: return "๐"
        case .health: return "๐ฉบ"
        case .housing: return "๐ "
        case .income: return "๐ฐ"
        case .investiment: return "๐ค"
        case .children: return "๐ธ"
        case .personalCare: return "๐"
        case .pet: return "๐พ"
        case .shopping: return "๐"
        case .taxes: return "๐"
        case .travel: return "โ๏ธ"
        case .transport: return "โฝ๏ธ"
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
