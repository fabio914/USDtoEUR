import Foundation

enum ExchangeRateAPIError: Error {
    case invalidURL
    case invalidStatusCode
    case networkError(Error)
    case missingData
}

struct ExchangeRateAPI {

    static func fetchExchangeRates() throws -> Data {

        let urlString = "https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/usd.xml"

        guard let url = URL(string: urlString) else {
            throw ExchangeRateAPIError.invalidURL
        }

        let urlRequest = URLRequest(url: url)
        let result = URLSession.shared.synchronousDataTask(with: urlRequest)

        if let error = result.2 {
            throw ExchangeRateAPIError.networkError(error)
        }

        guard let statusCode = (result.1 as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
            throw ExchangeRateAPIError.invalidStatusCode
        }

        guard let data = result.0 else {
            throw ExchangeRateAPIError.missingData
        }

        return data
    }
}
