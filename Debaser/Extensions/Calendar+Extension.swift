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

    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: today, toGranularity: .weekOfYear)
    }
}
