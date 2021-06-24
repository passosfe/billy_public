//
//  Date+Formatting.swift
//  Billy
//
//  Created by Felipe Passos on 24/11/20.
//

import Foundation

extension Date {
    func getFormattedDate(format: String, locale: String? = nil) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        if let locale = locale {
            dateformat.locale = Locale(identifier: locale)
        } else {
            dateformat.locale = Locale.current
        }
        return dateformat.string(from: self)
    }
    
    func getFormattedDateLocalized() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current)
        return dateFormatter.string(from: self)
    }
}
