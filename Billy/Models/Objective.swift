//
//  Objective.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import Foundation
import FirebaseFirestoreSwift

struct Objective: Codable {
    @DocumentID var id: String?
    var title: String
    var description: String?
    var dateLimit: Date
    var startDate: Date
    var targetAmmount: Int
    var accountsAmmount: [String: [AmmountsHistory]]?
}

struct AmmountsHistory: Codable, Identifiable, Hashable {
    var id: String
    var accountId: String
    var date: Date
    var ammount: Int
}
