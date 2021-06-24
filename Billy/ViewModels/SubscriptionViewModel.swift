//
//  SubscriptionViewModel.swift
//  Billy
//
//  Created by Felipe Passos on 29/12/20.
//

import Foundation
import Firebase
import Combine
import Purchases
import SwiftUI

final class SubscriptionViewModel: ObservableObject {
    private let purchaseService: PurchaseServiceProtocol
    private var cancellables: [AnyCancellable] = [AnyCancellable]()
    
    @Published private(set) var products: [Purchases.Package] = [Purchases.Package]()
    @Published private(set) var selectedProduct: Purchases.Package?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var introductoryPriceText: String?
    @Published var error: BillyError?
    @Binding var isShowing: Bool
    
    var biggestPrice: Decimal {
        products.reduce(0) { max($0, totalInOneYear(for: $1.product.price as Decimal, in: $1.product.subscriptionPeriod?.unit.rawValue)) }
    }
    
    enum Action {
        case selectProduct(Purchases.Package)
        case restorePurchases
        case makePurchase
        case close
        case redemptionCode
    }
    
    init(isShowing: Binding<Bool>, purchaseService: PurchaseServiceProtocol = PurchaseService()) {
        self.purchaseService = purchaseService
        self._isShowing = isShowing
        fetchAvailableProducts()
    }
    
    func send(action: Action) {
        switch action {
        case .selectProduct(let product):
            self.selectedProduct = product
        case .makePurchase:
            self.subscribe()
        case .restorePurchases:
            self.restorePurchases()
        case .close:
            self.isShowing = false
        case .redemptionCode:
            self.redemptionCode()
        }
    }
    
    func subscriptionItemTitle(for value: Decimal, in period: UInt?, at locale: Locale) -> String {
        if let period = period {
            return "\(NumberFormatter.currencyFormatter(for: locale).string(from: value as NSNumber)!) / \(unitName(unitRawValue: period))"
        } else {
            return ""
        }
    }
    
    func subscriptionItemSubtitle(for value: Decimal, in period: UInt?, at locale: Locale) -> String {
        if let period = period {
            switch period {
            case 2:
                return Strings.chargedMonthly.toLocalizedString
            case 3:
                return "\(NumberFormatter.currencyFormatter(for: locale).string(from: (value / 12) as NSNumber)!) \(Strings.per.toLocalizedString) \(unitName(unitRawValue: 2)), \(Strings.chargedAnnualy.toLocalizedString)"
            default:
                return ""
            }
        } else {
            return ""
        }
    }
    
    func savingPercentage(for value: Decimal, in period: UInt?) -> Int32 {
        if let period = period {
            let totalValue = totalInOneYear(for: value, in: period)
            return ((((biggestPrice - totalValue) / biggestPrice) * 100) as NSDecimalNumber).int32Value
        } else {
            return 0
        }
    }
    
    private func fetchAvailableProducts() {
        isLoading = true
        purchaseService.listAvailablePackages().sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] products in
            guard let self = self else { return }
            self.error = nil
            self.products = products
            self.selectedProduct = products.first
            if let product = products.first {
                if let introductoryPrice = product.product.introductoryPrice {
                    self.introductoryPriceText = "\(Strings.startYour.toLocalizedString) \(introductoryPrice.subscriptionPeriod.numberOfUnits) \(self.unitName(unitRawValue: introductoryPrice.subscriptionPeriod.unit.rawValue)) \(Strings.freeTrial.toLocalizedString)"
                }
            }
            self.isLoading = false
        }.store(in: &cancellables)
    }
    
    private func totalInOneYear(for price: Decimal, in period: UInt?) -> Decimal {
        if let period = period {
            switch period {
            case 0: return price * 365
            case 1: return price * 52
            case 2: return price * 12
            case 3: return price * 1
            default: return price
            }
        } else {
            return price
        }
    }
    
    private func subscribe(discount: SKPaymentDiscount? = nil) {
        isLoading = true
        guard let selectedProduct = self.selectedProduct else { return }
        purchaseService.makePurchase(package: selectedProduct, discount: discount).sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] result in
            guard let self = self else { return }
            self.error = nil
            self.isLoading = false
            if result == .success {
                self.isShowing = false
            }
        }.store(in: &cancellables)
    }
    
    private func redemptionCode() {
        Purchases.shared.presentCodeRedemptionSheet()
    }
    
    private func restorePurchases() {
        isLoading = true
        purchaseService.restorePurchases().sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.error = nil
            self.isLoading = false
            self.isShowing = false
        }.store(in: &cancellables)
    }
    
    private func unitName(unitRawValue:UInt) -> String {
        switch unitRawValue {
        case 0: return "day"
        case 1: return Strings.week.toLocalizedString.lowercased()
        case 2: return Strings.month.toLocalizedString.lowercased()
        case 3: return Strings.year.toLocalizedString.lowercased()
        default: return ""
        }
    }
    
    func planPeriod(for period: UInt) -> String {
        switch period {
        case 0: return "days"
        case 1: return "weeks"
        case 2: return Strings.month.toLocalizedString
        case 3: return Strings.month.toLocalizedString
        default: return ""
        }
    }
    
    let subscriptionBenefits: SubscriptionBenefit = .init(titles: [
        Strings.collabUsers.toLocalizedString,
        Strings.objectives.toLocalizedString,
        Strings.bankAccounts.toLocalizedString,
        Strings.categoryLimits.toLocalizedString,
        Strings.budgets.toLocalizedString,
    ], freeLimits: [
        RCValues.sharedInstance.ammount(for: .maxUserPerBudget),
        RCValues.sharedInstance.ammount(for: .maxObjectives),
        RCValues.sharedInstance.ammount(for: .maxBankAccounts),
        RCValues.sharedInstance.ammount(for: .maxCategoryLimits),
        RCValues.sharedInstance.ammount(for: .maxBudgets),
    ])
}
