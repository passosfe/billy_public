//
//  TransactionItem.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import Foundation
import FirebaseFirestoreSwift

struct Transaction: Codable {
    @DocumentID var id: String?
    
    let description: String?
    let type: TransactionType
    let date: Date
    let ammount: Int
    let category: StandardCategory?
    let fromAccount: String
    let toAccount: String?
    let docId: String?
}

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case transfer
    case income
    
    var icon: String {
        switch self {
        case .expense:
            return "arrow.down.right"
        case .income:
            return "arrow.up.right"
        case .transfer:
            return "arrow.left.arrow.right"
        }
    }
    
    var categoriesRelated: [StandardCategory] {
        switch self {
        case .expense:
            return [.amusement, .bills, .children, .education, .fees, .finance, .food, .health, .housing, .personalCare, .pet, .presents, .shopping, .taxes, .transport, .travel]
        case .income:
            return [.income, .investiment]
        default:
            return []
        }
    }
    
    var toLocalizedString: String { NSLocalizedString(rawValue, comment: "") }
}
