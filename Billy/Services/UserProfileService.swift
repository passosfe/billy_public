//
//  UserProfileService.swift
//  Billy
//
//  Created by Felipe Passos on 27/12/20.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UserProfileServiceProtocol {
    func create(_ userProfile: UserProfile, userId: String) -> AnyPublisher<Void, BillyError>
    func addUserPermission(_ newPermission: NewPermission) -> AnyPublisher<Void, BillyError>
    func acceptUserPermission(userId: String, newPermission: NewPermission) -> AnyPublisher<Void, BillyError>
    func rejectUserPermission(userId: String, newPermission: NewPermission) -> AnyPublisher<Void, BillyError>
    func observeUserProfile(userId: String) -> AnyPublisher<UserProfile, BillyError>
}

final class UserProfileService: UserProfileServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ userProfile: UserProfile, userId: String) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                _ = try self.db.collection("userProfiles").document(userId).setData(from: userProfile, merge: true) { error in
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
    
    func addUserPermission(_ newPermission: NewPermission) -> AnyPublisher<Void, BillyError> {
        let updateData = [
            "fromEmail": newPermission.fromEmail,
            "toEmail": newPermission.toEmail,
            "budgetID": newPermission.budgetID,
            "budgetName": newPermission.budgetName,
            "permissionType": newPermission.permissionType.rawValue
        ]
        return Future<Void, BillyError> { promise in
            self.db.collection("userProfiles").whereField("email", isEqualTo: newPermission.toEmail).limit(to: 1).getDocuments() {(querySnapshot, err) in
                if let err = err {
                    promise(.failure(.default(description: err.localizedDescription)))
                } else if querySnapshot!.documents.isEmpty {
                    promise(.failure(.default(description: "userEmailNotFound")))
                } else {
                    if let document = querySnapshot!.documents.first {
                        document.reference.updateData([
                            "newPermissions": FieldValue.arrayUnion([updateData])
                        ])
                    }
                    promise(.success(()))
                }}
        }.eraseToAnyPublisher()
    }
    
    func acceptUserPermission(userId: String, newPermission: NewPermission) -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            do {
                _ = try self.db.collection("userProfiles").document(userId).collection("acceptedPermissions").addDocument(from: newPermission) { error in
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
    
    func rejectUserPermission(userId: String, newPermission: NewPermission) -> AnyPublisher<Void, BillyError> {
        let updateData = [
            "fromEmail": newPermission.fromEmail,
            "toEmail": newPermission.toEmail,
            "budgetID": newPermission.budgetID,
            "budgetName": newPermission.budgetName,
            "permissionType": newPermission.permissionType.rawValue
        ]
        return Future<Void, BillyError> { promise in
            self.db.collection("userProfiles").document(userId).updateData([
                "newPermissions": FieldValue.arrayRemove([updateData])
            ]) { error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func observeUserProfile(userId: String) -> AnyPublisher<UserProfile, BillyError> {
        let documentReference = self.db.collection("userProfiles").document(userId)
        
        return Publishers.DocumentSnapshotPublisher(documentReference: documentReference,
                                                    addListener: { $0.addSnapshotListener($1) },
                                                    removeListener: { $0.remove() })
            .flatMap { snapShot -> AnyPublisher<UserProfile, BillyError> in
                do {
                    let userProfile = try snapShot.data(as: UserProfile.self)
                    return Just(userProfile ?? UserProfile(id: "1", email: ""))
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
