import Foundation

enum ExchangeRateManagerError: Error {
    case missingExchangeRates
    case unableToFindExchangeRate
}

final class ExchangeRateManager {
    private let exchangeRates: [Date: [ExchangeRate]]

    private let initialExchangeRate: ExchangeRate
    private var initialDate: Date { initialExchangeRate.date }

    private let finalExchangeRate: ExchangeRate
    private var finalDate: Date { finalExchangeRate.date }

    init(exchangeRates: [ExchangeRate]) throws {
        self.exchangeRates = exchangeRates.groupBy({ $0.date })

        guard let initialExchangeRate = exchangeRates.min(by: { $0.date < $1.date }),
            let finalExchangeRate = exchangeRates.max(by: { $0.date < $1.date })
        else {
            throw ExchangeRateManagerError.missingExchangeRates
        }

        self.initialExchangeRate = initialExchangeRate
        self.finalExchangeRate = finalExchangeRate
    }

    private func exactExchangeRate(for date: Date) throws -> ExchangeRate? {
        if date < initialDate {
            throw ExchangeRateManagerError.unableToFindExchangeRate
        }

        // We're using the latest exchange rate available if the date is in the future
        if date > finalDate {
            return finalExchangeRate
        }

        return exchangeRates[date]?.first
    }

    func exchangeRate(for date: Date) throws -> ExchangeRate {
        var dateToUse = date

        while try exactExchangeRate(for: dateToUse) == nil {
            if let previousDate = dateToUse.previousDay {
                dateToUse = previousDate
            } else {
                throw ExchangeRateManagerError.unableToFindExchangeRate
            }
        }

        guard let exchangeRate = try exactExchangeRate(for: dateToUse) else {
            throw ExchangeRateManagerError.unableToFindExchangeRate
        }

        return exchangeRate
    }
}
