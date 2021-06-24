//
//  Constants.swift
//  Billy
//
//  Created by Felipe Passos on 13/11/20.
//

import Foundation

enum Strings: String {
    // MARK: - TabView Strings
    case home
    case objectives
    case profile
    
    // MARK: - Create
    case selectToCreate
    case account
    case transaction
    case monthLimit
    
    // MARK: - HomeCards Strings
    case seeAll
    case categories
    case defineYourLimits
    case registerFirstTransaction
    
    // MARK: - Balance
    case totalBalance
    case available
    case frozen
    
    // MARK: - Transactions
    case transactions
    case editAction
    case save
    case category
    
    // MARK: - Main Chart labels
    case week
    case month
    case year
    case weekSpendings
    case monthSpendings
    case yearSpendings
    case spendings
    
    // MARK: - Onboarding
    case onboardingOneTitle
    case onboardingOneBody
    case onboardingTwoTitle
    case onboardingTwoBody
    case onboardingThreeTitle
    case onboardingThreeBody
    case next
    case start
    case skip
    
    // MARK: - Budget
    case initialBudget
    case mainBudget
    case budget
    
    // MARK: - Create Bank Account
    case currentBalance
    case balance
    case alias
    case description
    case fillAllFields
    case create
    case new
    case myAccount
    case initialAccount
    
    // MARK: - Create Transaction
    case fromAccount
    case toAccount
    case date
    
    // MARK: - Create Month Limit
    case limit
    
    // MARK: - Objectives
    case days
    case weeks
    case months
    case years
    case formTitle
    case formValue
    case addMoney
    case withdraw
    case history
    case timeLeft
    case objective
    case newMale
    case registerFirstObjective
    
    // MARK: - Validation
    case mustNotBeEmpty
    case mustBeAboveOf
    case mustBeUnderOf
    
    // MARK: - Login
    case welcomeBack
    case createAccount
    case enterWithAccount
    case registerAndKeep
    case signInWith
    case signUpWith
    case pronounO
    case pronounA
    case alreadyUser
    case here
    case logoutWarningMessage
    case warning
    case leaveAnyway
    case logout
    case register
    case deleteAccount
    case deleteAccountWarning
    case confirmation
    
    // MARK: - Accounts
    case accounts
    case accountName
    case bankAccounts
    case ops
    case atLeastOneAccount
    case total
    
    // MARK: - Subscriptions
    case subscribe
    case reachedLimit
    case chargedMonthly
    case per
    case chargedAnnualy
    case startYour
    case freeTrial
    case congratulations
    case becomePremium
    case alreadyPremium
    case subscribeAndUnlock
    case purchaseAcknowledgementText
    case termsOfUse
    case privacyPolicy
    case restorePurchases
    case subscription
    case unlockFullAccess
    case spare
    case collabUsers
    case categoryLimits
    case budgets
    case checkAllIncluded
    case free
    case premium
    case unlimited
    case feature
    
    // MARK: - Permissions
    case permissions
    case add
    case me
    case emailToAdd
    case permission
    case invitedYouTo
    case doYouAccept
    case theBudget
    case accept
    case reject
    
    // MARK: - Notifications
    case notifications
    
    // MARK: - ToLocalized
    var toLocalizedString: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
