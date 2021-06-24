//
//  FirebaseConfigService.swift
//  Billy
//
//  Created by Felipe Passos on 31/12/20.
//

import Foundation
import Combine
import Firebase

protocol RemoteConfigServiceProtocol {
    func fetchValues() -> AnyPublisher<Void, BillyError>
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    func fetchValues() -> AnyPublisher<Void, BillyError> {
        return Future<Void, BillyError> { promise in
            let fetchDuration: TimeInterval = 0
              RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                RemoteConfig.remoteConfig().activate() { (changed, error) in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    promise(.success(()))
                  }
              }
        }.eraseToAnyPublisher()
    }
}
