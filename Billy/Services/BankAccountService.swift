//
//  BankAccountService.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol BankAccountServiceProtocol {
    func create(_ bankAccount: Account, budgetId: String) -> AnyPublisher<Void, BillyError>
    func delete(_ accountId: String, budgetId: String) -> AnyPublisher<Void, BillyError>
}

final class BankAccountService: BankAccountServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ bankAccount: Account, budgetId: String) -> AnyPublisher<Void, BillyError> {
        var account: [String: Any] = [
            "id": bankAccount.id,
            "type": bankAccount.type.rawValue,
            "name": bankAccount.name,
            "freeBalance": bankAccount.freeBalance,
            "description": bankAccount.description
        ]
        
        if let frozenBalance = bankAccount.frozenBalance {
            account["frozenBalance"] = frozenBalance
        }
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).setData(
                [
                    "bankAccounts": [
                        bankAccount.id: account
                    ],
                ],
                merge: true
            )
            { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(_ accountId: String, budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).setData(
                [
                    "bankAccounts": [
                        accountId: FieldValue.delete()
                    ],
                ],
                merge: true
            )
            { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
