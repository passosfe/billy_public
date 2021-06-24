//
//  Validation.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation
import Combine

typealias ValidationErrorClosure = () -> String

typealias ValidationPublisher = AnyPublisher<Validation, Never>

class ValidationPublishers {

    // Validates whether a string property is non-empty.
    static func nonEmptyValidation(for publisher: Published<String>.Publisher,
                                   errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return publisher.map { value in
            guard value.count > 0 else {
                return .failure(message: errorMessage())
            }
            return .success
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
    
    // Validates whether a string matches a regular expression.
    static func matcherValidation(for publisher: Published<String>.Publisher,
                                  withPattern pattern: NSPredicate,
                                  errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return publisher.map { value in
            guard pattern.evaluate(with: value) else {
                return .failure(message: errorMessage())
            }
            return .success
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
    
    // Validates whether a date falls between two other dates. If one of
    // the bounds isn't provided, a suitable distant detail is used.
    static func dateValidation(for publisher: Published<Date>.Publisher,
                               afterDate after: Date = .distantPast,
                               beforeDate before: Date = .distantFuture,
                               errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return publisher.map { date in
            return date > after && date < before ? .success : .failure(message: errorMessage())
        }.eraseToAnyPublisher()
    }
    
    //
    //
    static func aboveValidation(for publisher: Published<String>.Publisher,
                                value: Double,
                                errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return publisher.map { aboveValue in
            return Double(aboveValue) ?? 0 > value ? .success : .failure(message: errorMessage())
        }.eraseToAnyPublisher()
    }
    
    //
    //
    static func underValidation(for publisher: Published<String>.Publisher,
                                value: Double,
                                errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        return publisher.map { aboveValue in
            return Double(aboveValue) ?? 0 < value ? .success : .failure(message: errorMessage())
        }.eraseToAnyPublisher()
    }

}
