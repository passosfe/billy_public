//
//  CategoryLimitService.swift
//  Billy
//
//  Created by Felipe Passos on 09/12/20.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol CategoryLimitServiceProtocol {
    func create(_ categoryLimit: CategoryLimit, budgetId: String) -> AnyPublisher<Void, BillyError>
    func observeCategoriesTransactions(budgetId: String) -> AnyPublisher<CategoryTransactions, BillyError> 
}

final class CategoryLimitService: CategoryLimitServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ categoryLimit: CategoryLimit, budgetId: String) -> AnyPublisher<Void, BillyError> {
        var category: [String: Any] = [
            "id": categoryLimit.id,
            "maxAvailable": categoryLimit.maxAvailable,
            "type": categoryLimit.type.rawValue,
            "key": categoryLimit.key
        ]
        if let lastTransactionAt = categoryLimit.lastTransactionAt {
            category["lastTransactionAt"] = lastTransactionAt
        }
        
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).setData(
                [
                    "categoriesLimits": [
                        categoryLimit.id: category,
                    ]
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
    
    func observeCategoriesTransactions(budgetId: String) -> AnyPublisher<CategoryTransactions, BillyError> {
        let documentReference = self.db.collection("budgets").document(budgetId).collection("months").document(self.getDocument(for: Date()).lowercased())
        
        return Publishers.DocumentSnapshotPublisher(documentReference: documentReference,
                                                    addListener: { $0.addSnapshotListener($1) },
                                                    removeListener: { $0.remove() })
            .flatMap { snapShot -> AnyPublisher<CategoryTransactions, BillyError> in
                do {
                    let categoryTransactions = try snapShot.data(as: CategoryTransactions.self)
                    return Just(categoryTransactions ?? CategoryTransactions(categoryTransactions: [:]))
                            .setFailureType(to: BillyError.self)
                            .eraseToAnyPublisher()
                } catch {
                    print(error)
                    return Fail(error: .default(description: "Parsing Error"))
                                .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
}

extension CategoryLimitService {
    private func getDocument(for date: Date) -> String {
        return date.getFormattedDate(format: "MMM_yyyy", locale: "en_US")
    }
}

