//
//  TransactionService.swift
//  Billy
//
//  Created by Felipe Passos on 25/11/20.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol TransactionServiceProtocol {
    func create(_ transaction: Transaction, budgetId: String) -> AnyPublisher<Void, BillyError>
    func getTransactions(date: Date, budgetId: String, limit: Int, lastDoc: DocumentSnapshot?, filterAccountId: String?) -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, transactions:[Transaction]), BillyError>
    func observeTransactions(budgetId: String, limit: Int) -> AnyPublisher<[Transaction], BillyError>
    func delete(_ transactionId: String, budgetId: String) -> AnyPublisher<Void, BillyError>
    func updateTransaction(_ transaction: Transaction, transactionDocId: String, budgetId: String) -> AnyPublisher<Void, BillyError>
}

final class TransactionService: TransactionServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ transaction: Transaction, budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                _ = try self.db.collection("budgets").document(budgetId).collection("transactions").addDocument(from: transaction) { error in
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
    
    func observeTransactions(budgetId: String, limit: Int = 5) -> AnyPublisher<[Transaction], BillyError> {
        let query = db.collection("budgets").document(budgetId).collection("transactions").order(by: "date", descending: true).limit(to: limit)
        return Publishers.QuerySnapshotPublisher(query: query,
                                                 addListener: { $0.addSnapshotListener($1) },
                                                 removeListener: { $0.remove() })
            .flatMap { snapShot -> AnyPublisher<[Transaction], BillyError> in
                do {
                    let transactions = try snapShot.documents.compactMap {
                        try $0.data(as: Transaction.self)
                    }
                    return Just(transactions)
                            .setFailureType(to: BillyError.self)
                            .eraseToAnyPublisher()
                } catch {
                    print(error)
                    return Fail(error: .default(description: "Parsing Error"))
                                .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
    func getTransactions(date: Date, budgetId: String, limit: Int = 10, lastDoc: DocumentSnapshot? = nil, filterAccountId: String? = nil) -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, transactions:[Transaction]), BillyError> {
        var query = self.db.collection("budgets")
            .document(budgetId)
            .collection("transactions")
            .whereField("date", isLessThanOrEqualTo: date.endOfMonth)
            .whereField("date", isGreaterThanOrEqualTo: date.startOfMonth)
            .order(by: "date", descending: true)
            .limit(to: limit)
        
        if let lastDocument = lastDoc {
            query = query.start(afterDocument: lastDocument)
        }
        
        if let accountId = filterAccountId {
            query = query.whereField("fromAccount", isEqualTo: accountId)
        }
        
        return Future<(lastDoc: QueryDocumentSnapshot?, transactions:[Transaction]), BillyError> { promise in
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else if let snapshot = snapshot {
                    do {
                        let transactions = try snapshot.documents.compactMap {
                            try $0.data(as: Transaction.self)
                        }
                        promise(.success((lastDoc: snapshot.documents.last, transactions: transactions)))
                    } catch {
                        promise(.failure(.default()))
                    }
                } else {
                    promise(.failure(.default()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(_ transactionId: String, budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).collection("transactions").document(transactionId).delete { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateTransaction(_ transaction: Transaction, transactionDocId: String, budgetId: String) -> AnyPublisher<Void, BillyError> {
        var updateData: [String: Any] = [
            "description": transaction.description ?? "",
            "transactionType": transaction.type.rawValue,
            "date": transaction.date,
            "ammount": transaction.ammount,
            "fromAccount": transaction.fromAccount
        ]
        
        if let category = transaction.category {
            updateData["category"] = category.rawValue
        } else {
            updateData["category"] = FieldValue.delete()
        }

        if let toAccount = transaction.toAccount {
            updateData["toAccount"] = toAccount
        } else {
            updateData["toAccount"] = FieldValue.delete()
        }
        
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).collection("transactions").document(transactionDocId).updateData(updateData)
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
