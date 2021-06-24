//
//  Currency+NumberFormatter.swift
//  Billy
//
//  Created by Felipe Passos on 16/11/20.
//

import Foundation

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter
    }
    
    static func currencyFormatter(for locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }
}
