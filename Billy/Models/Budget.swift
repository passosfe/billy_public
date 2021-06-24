//
//  Budget.swift
//  Billy
//
//  Created by Felipe Passos on 19/11/20.
//

import Foundation
import FirebaseFirestoreSwift

struct Budget: Codable, Identifiable, Equatable {
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        lhs.id == rhs.id
    }
    
    @DocumentID var id: String?
    var title: String
    var userPermissions: [String: UserPermission]
    var categoriesLimits: [String: CategoryLimit]?
    var spendingHistory: [String: [String: [String: SpendingHistoryData]]]?
    var bankAccounts: [String: Account]?
}

struct SpendingHistoryData: Codable {
    var date: Date
    var spendings: Int
}

struct UserPermission: Codable {
    var email: String?
    var permission: PermissionTypes
}

enum PermissionTypes: String, Codable, CaseIterable, Hashable {
    case edit
    case read
    
    var toLocalizedString: String { NSLocalizedString(rawValue, comment: "") }
}
