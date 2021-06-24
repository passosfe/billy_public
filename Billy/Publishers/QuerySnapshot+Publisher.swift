//
//  QuerySnapshotPublisher.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import Combine
import Firebase

extension Publishers {
    
    struct QuerySnapshotPublisher: Publisher {
        
        typealias Output = QuerySnapshot
        typealias Failure = BillyError
        
        private let query: Query
        private let addListener: (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration
        private let removeListener: (ListenerRegistration) -> Void
        
        init(query: Query, addListener: @escaping (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration, removeListener: @escaping (ListenerRegistration) -> Void) {
            self.query = query
            self.addListener = addListener
            self.removeListener = removeListener
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let querySnapshotSubscription = QuerySnapshotSubscription(subscriber: subscriber, query: query, addListener: addListener, removeListener: removeListener)
            subscriber.receive(subscription: querySnapshotSubscription)
        }
    }
    
    class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == QuerySnapshot, S.Failure == BillyError {
        
        private var subscriber: S?
        private var listener: ListenerRegistration?
        private var _cancel: (() -> Void)? = nil
        
        init(subscriber: S, query: Query, addListener: @escaping (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration, removeListener: @escaping (ListenerRegistration) -> Void) {
            listener = addListener(query) { querySnapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                } else if let querySnapshot = querySnapshot {
                    _ = subscriber.receive(querySnapshot)
                } else {
                    subscriber.receive(completion: .failure(.default()))
                }
            }
            
            self._cancel = {
                removeListener(self.listener!)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        public func cancel() {
            if let remove = _cancel {
                remove()
            }
            subscriber = nil
        }
    }
}
