//
//  Calendar+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-28.
//

import Foundation

extension Calendar {
    
    private var today: Date {
        return Date()
    }

    ///
    /// Checks if a specific date is in the current week
    ///
    /// - Parameter date: The date to check for
    /// - Returns: A boolean whether date is in the current week or not
    ///
    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: today, toGranularity: .weekOfYear)
    }
    
}
