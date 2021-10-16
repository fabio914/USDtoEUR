import Foundation

enum ExchangeRateParserError: Error {
    case missingObservations
    case failedToParse(XMLElement)
}

struct ExchangeRateParser {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func parse(_ root: XMLElement) throws -> [ExchangeRate] {
        guard let compactData = root["CompactData"]?.first,
            let dataSet = compactData["DataSet"]?.first,
            let series = dataSet["Series"]?.first,
            let observations = series["Obs"],
            !observations.isEmpty
        else {
            throw ExchangeRateParserError.missingObservations
        }

        return try observations.map(parseObservation)
    }

    private static func parseObservation(_ element: XMLElement) throws -> ExchangeRate {
        guard let dateString = element.attributeDict["TIME_PERIOD"],
            let date = Self.dateFormatter.date(from: dateString),
            let eurToUsdString = element.attributeDict["OBS_VALUE"],
            let eurToUsd = Double(eurToUsdString)
        else {
            throw ExchangeRateParserError.failedToParse(element)
        }

        return ExchangeRate(date: date, eurToUsd: eurToUsd)
    }
}
