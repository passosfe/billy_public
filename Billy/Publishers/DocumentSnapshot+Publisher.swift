//
//  DocumentSnapshot+Publisher.swift
//  Billy
//
//  Created by Felipe Passos on 10/12/20.
//

import Foundation
import Combine
import Firebase

extension Publishers {
    struct DocumentSnapshotPublisher: Publisher {
        
        typealias Output = DocumentSnapshot
        typealias Failure = BillyError
        
        private let documentReference: DocumentReference
        private let addListener: (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration
        private let removeListener: (ListenerRegistration) -> Void
        
        init(documentReference: DocumentReference, addListener: @escaping (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration, removeListener: @escaping (ListenerRegistration) -> Void) {
            self.documentReference = documentReference
            self.addListener = addListener
            self.removeListener = removeListener
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let documentSnapshotSubscription = DocumentSnapshotSubscription(subscriber: subscriber, documentReference: documentReference, addListener: addListener, removeListener: removeListener)
            subscriber.receive(subscription: documentSnapshotSubscription)
        }
    }

    class DocumentSnapshotSubscription<S: Subscriber>: Subscription where S.Input == DocumentSnapshot, S.Failure == BillyError {
        
        private var subscriber: S?
        private var listener: ListenerRegistration?
        private var _cancel: (() -> Void)? = nil
        
        init(subscriber: S, documentReference: DocumentReference, addListener: @escaping (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration, removeListener: @escaping (ListenerRegistration) -> Void) {
            listener = addListener(documentReference) { documentSnapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                } else if let documentSnapshot = documentSnapshot {
                    _ = subscriber.receive(documentSnapshot)
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
        
        func cancel() {
            if let remove = _cancel {
                remove()
            }
            listener = nil
        }
    }
}
