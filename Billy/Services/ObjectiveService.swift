//
//  ObjectiveService.swift
//  Billy
//
//  Created by Felipe Passos on 14/12/20.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ObjectiveServiceProtocol {
    func create(_ objective: Objective, budgetId: String) -> AnyPublisher<Void, BillyError>
    func getObjectives(budgetId: String, lastDoc: DocumentSnapshot?, limit: Int) -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, objectives:[Objective]), BillyError>
    func observeObjective(budgetId: String, objectiveId: String) -> AnyPublisher<Objective, BillyError>
    func delete(_ objectiveId: String, budgetId: String) -> AnyPublisher<Void, BillyError>
    func updateObjective(_ objective: Objective, objectiveID: String, budgetId: String) -> AnyPublisher<Void, BillyError>
    func insertTransaction(_ transaction: AmmountsHistory, objective: Objective, budgetId: String) -> AnyPublisher<Void, BillyError>
}

final class ObjectiveService: ObjectiveServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ objective: Objective, budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                _ = try self.db.collection("budgets").document(budgetId).collection("objectives").addDocument(from: objective) { error in
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
    
    func getObjectives(budgetId: String, lastDoc: DocumentSnapshot?, limit: Int = 3) -> AnyPublisher<(lastDoc: QueryDocumentSnapshot?, objectives:[Objective]), BillyError> {
        var query = db.collection("budgets").document(budgetId).collection("objectives").order(by: "dateLimit").limit(to: limit)
        
        if let lastDocument = lastDoc {
            query = query.start(afterDocument: lastDocument)
        }
        
        return Future<(lastDoc: QueryDocumentSnapshot?, objectives:[Objective]), BillyError> { promise in
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else if let snapshot = snapshot {
                    do {
                        let objectives = try snapshot.documents.compactMap {
                            try $0.data(as: Objective.self)
                        }
                        promise(.success((lastDoc: snapshot.documents.last, objectives: objectives)))
                    } catch {
                        promise(.failure(.default()))
                    }
                } else {
                    promise(.failure(.default()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func observeObjective(budgetId: String, objectiveId: String) -> AnyPublisher<Objective, BillyError> {
        let documentReference = self.db.collection("budgets").document(budgetId).collection("objectives").document(objectiveId)
        
        return Publishers.DocumentSnapshotPublisher(documentReference: documentReference,
                                                    addListener: { $0.addSnapshotListener($1) },
                                                    removeListener: { $0.remove() })
            .flatMap { snapShot -> AnyPublisher<Objective, BillyError> in
                do {
                    let objective = try snapShot.data(as: Objective.self)
                    return Just(objective ?? Objective(id: "1", title: "", description: nil, dateLimit: Date(), startDate: Date(), targetAmmount: 0, accountsAmmount: nil))
                            .setFailureType(to: BillyError.self)
                            .eraseToAnyPublisher()
                } catch {
                    print(error)
                    return Fail(error: .default(description: "Parsing Error"))
                                .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
    func delete(_ objectiveId: String, budgetId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).collection("objectives").document(objectiveId).delete { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateObjective(_ objective: Objective, objectiveID: String, budgetId: String) -> AnyPublisher<Void, BillyError> {
        var updateData: [String: Any] = [
            "title": objective.title,
            "dateLimit": objective.dateLimit,
            "targetAmmount": objective.targetAmmount
        ]
        if let description = objective.description {
            updateData["description"] = description
        } else {
            updateData["description"] = FieldValue.delete()
        }
        
        if let accountsAmmount = objective.accountsAmmount {
            updateData["accountsAmmount"] = accountsAmmount
        } else {
            updateData["accountsAmmount"] = FieldValue.delete()
        }
        
        return Future<Void, BillyError> { promise in
            self.db.collection("budgets").document(budgetId).collection("objectives").document(objectiveID).updateData(updateData)
            { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func insertTransaction(_ transaction: AmmountsHistory, objective: Objective, budgetId: String) -> AnyPublisher<Void, BillyError> {
        let newItem: [String: Any] = [
            "id": transaction.id,
            "accountId": transaction.accountId,
            "date": transaction.date,
            "ammount": transaction.ammount
        ]
        if let transactions = objective.accountsAmmount, transactions.count > 0 {
            return Future<Void, BillyError> { promise in
                self.db.collection("budgets").document(budgetId).collection("objectives").document(objective.id!).setData([
                        "accountsAmmount": [
                            transaction.accountId: FieldValue.arrayUnion([newItem])
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
        } else {
            return Future<Void, BillyError> { promise in
                self.db.collection("budgets").document(budgetId).collection("objectives").document(objective.id!).setData([
                        "accountsAmmount": [
                            transaction.accountId: [newItem]
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
}
