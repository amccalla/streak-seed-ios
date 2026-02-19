//
//  Date+Extensions.swift
//  StreakSeed
//

import Foundation

extension Date {
    /// Normalizes to start-of-day in the user's local calendar.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the date for the start of today.
    static var today: Date {
        Date().startOfDay
    }

    /// True if this date falls on the same calendar day as `other`.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Number of calendar days between two dates (negative if `self` is before `other`).
    func daysSince(_ other: Date) -> Int {
        let cal = Calendar.current
        let from = cal.startOfDay(for: other)
        let to = cal.startOfDay(for: self)
        return cal.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// Returns an array of dates for the last `n` days ending today.
    static func lastNDays(_ n: Int) -> [Date] {
        let cal = Calendar.current
        let today = Date.today
        return (0..<n).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    /// Returns all dates in the same month as this date.
    func datesInMonth() -> [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: self),
              let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: self))
        else { return [] }

        return range.compactMap { day in
            cal.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    /// Weekday index (1 = Sunday ... 7 = Saturday).
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// Short day name (e.g., "Mon").
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    /// Single-letter day name (e.g., "M").
    var singleLetterDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: self)
    }

    /// Day number in month (e.g., 15).
    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Month and year string (e.g., "January 2025").
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Advance or go back by `months` months.
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
}
