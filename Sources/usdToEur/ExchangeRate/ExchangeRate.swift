import Foundation

struct ExchangeRate {
    let date: Date
    let eurToUsd: Double
    var usdToEur: Double { 1.0/eurToUsd }
}
