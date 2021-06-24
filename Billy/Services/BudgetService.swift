//
//  BudgetService.swift
//  Billy
//
//  Created by Felipe Passos on 19/11/20.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol BudgetServiceProtocol {
    func create(_ budget: Budget) -> AnyPublisher<Void, BillyError>
    func observeBudgets(userId: UserId) -> AnyPublisher<[Budget], BillyError>
    func delete(_ budgetId: String) -> AnyPublisher<Void, BillyError>
    func updateBudget(_ budgetId: String, newUserIdToShare: String, permissionType: PermissionTypes) -> AnyPublisher<Void, BillyError>
}

final class BudgetService: BudgetServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ budget: Budget) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                _ = try self.db.collection("budgets").addDocument(from: budget) { error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(.default()))
            }
        }.eraseToAnyPublisher()
    }
    
    func observeBudgets(userId: UserId) -> AnyPublisher<[Budget], BillyError> {
        let query = db.collection("budgets").whereField("userPermissions.\(userId).permission", in: ["edit", "read"])
        return Publishers.QuerySnapshotPublisher(query: query,
                                                 addListener: { $0.addSnapshotListener($1) },
                                                 removeListener: { $0.remove() })
            .flatMap { snapShot -> AnyPublisher<[Budget], BillyError> in
                do {
                    let budgets = try snapShot.documents.compactMap {
                        try $0.data(as: Budget.self)
                    }
                    return Just(budgets)
                            .setFailureType(to: BillyError.self)
                            .eraseToAnyPublisher()
                } catch {
                    print(error)
                    return Fail(error: .default(description: "Parsing Error"))
                                .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
    func delete(_ budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).delete { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateBudget(_ budgetId: String, newUserIdToShare: String, permissionType: PermissionTypes) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).setData(
                [
                    "userPermissions": [
                        newUserIdToShare: permissionType,
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
}
