//
//  PurchaseService.swift
//  Billy
//
//  Created by Felipe Passos on 29/12/20.
//

import Foundation
import Purchases
import Combine

protocol PurchaseServiceProtocol {
    func isPremiumUser() -> AnyPublisher<Bool, BillyError>
    func listAvailablePackages() -> AnyPublisher<[Purchases.Package], BillyError>
    func makePurchase(package: Purchases.Package, discount: SKPaymentDiscount?) -> AnyPublisher<PurchaseService.PurchaseReturn, BillyError>
    func restorePurchases() -> AnyPublisher<Bool, BillyError>
}

final class PurchaseService: PurchaseServiceProtocol {
    func isPremiumUser() -> AnyPublisher<Bool, BillyError> {
        return Future<Bool, BillyError> { promise in
            Purchases.shared.purchaserInfo { (purchaserInfo, error) in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                if purchaserInfo?.entitlements["allaccess"]?.isActive == true {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func listAvailablePackages() -> AnyPublisher<[Purchases.Package], BillyError> {
        return Future<[Purchases.Package], BillyError> { promise in
            Purchases.shared.offerings { (offerings, error) in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                if let packages = offerings?.current?.availablePackages {
                    promise(.success(packages))
                } else {
                    promise(.failure(.default(description: "noOfferingsFound")))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func makePurchase(package: Purchases.Package, discount: SKPaymentDiscount? = nil) -> AnyPublisher<PurchaseReturn, BillyError> {
        return Future<PurchaseReturn, BillyError> { promise in
            if let discount = discount {
                Purchases.shared.purchasePackage(package, discount: discount) { (transaction, purchaserInfo, error, userCancelled) in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    if purchaserInfo?.entitlements["allaccess"]?.isActive == true {
                        promise(.success(.success))
                    } else {
                        promise(.success(.userCancelled))
                    }
                }
            } else {
                Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    if purchaserInfo?.entitlements["allaccess"]?.isActive == true {
                        promise(.success(.success))
                    } else {
                        promise(.success(.userCancelled))
                    }
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    func restorePurchases() -> AnyPublisher<Bool, BillyError> {
        return Future<Bool, BillyError> { promise in
            Purchases.shared.restoreTransactions { (purchaserInfo, error) in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                if purchaserInfo?.entitlements["allaccess"]?.isActive == true {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    enum PurchaseReturn: String {
        case userCancelled
        case success
    }
}
