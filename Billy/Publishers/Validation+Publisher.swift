//
//  Validation.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import Combine

extension Published.Publisher where Value == String {
    
    func nonEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.nonEmptyValidation(for: self, errorMessage: errorMessage())
    }
    
    func matcherValidation(_ pattern: NSPredicate, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.matcherValidation(for: self, withPattern: pattern, errorMessage: errorMessage())
    }
    
    func aboveValidation(_ value: Double, errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.aboveValidation(for: self, value: value, errorMessage: errorMessage())
    }
    
    func underValidation(_ value: Double, errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.underValidation(for: self, value: value, errorMessage: errorMessage())
    }
}

extension Published.Publisher where Value == Date {
     func dateValidation(afterDate after: Date = .distantPast,
                         beforeDate before: Date = .distantFuture,
                         errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return ValidationPublishers.dateValidation(for: self, afterDate: after, beforeDate: before, errorMessage: errorMessage())
    }
}
