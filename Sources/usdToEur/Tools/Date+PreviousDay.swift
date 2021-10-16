import Foundation

extension Date {

    var previousDay: Date? {
        Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
}
