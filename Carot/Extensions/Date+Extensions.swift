//
//  Date+Extensions.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Foundation

extension Date {
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func daysBefore(_ n: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -n, to: noon)!
    }
    
    func daysAfter(_ n: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: n, to: noon)!
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}
