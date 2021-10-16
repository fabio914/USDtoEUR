import Foundation

let version = "1.0.0"

var err = FileHandle.standardError

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

func fatal(_ string: String) {
    print(string, to: &err)
    exit(1)
}

let inputDateFormatter = DateFormatter()
inputDateFormatter.dateFormat = "yyyy-MM-dd"

let outputDateFormatter = DateFormatter()
outputDateFormatter.dateStyle = .medium
outputDateFormatter.timeStyle = .none

let amountFormatter = NumberFormatter()
amountFormatter.numberStyle = .decimal
amountFormatter.roundingMode = .halfUp
amountFormatter.maximumFractionDigits = 2

let exchangeRateFormatter = NumberFormatter()
exchangeRateFormatter.numberStyle = .decimal
exchangeRateFormatter.roundingMode = .halfUp
exchangeRateFormatter.maximumFractionDigits = 4

let brightWhite = "\u{001B}[1;97m"
let disable = "\u{001B}[0;0m"

main(arguments: CommandLine.arguments)

func main(arguments: [String]) {

    guard arguments.count >= 2 else {
        fatal(
            """
            Version: \(version)

            \(brightWhite)\(CommandLine.arguments.first ?? "usdToEur")\(disable) <Date yyyy-MM-dd> <amount (optional)>
            """
        )
        return
    }

    let dateString = arguments[1]

    guard let date = inputDateFormatter.date(from: dateString) else {
        fatal("Error: Invalid date")
        return
    }

    let amount: Double? = {
        guard arguments.count > 2 else { return nil }

        guard let amount = Double(arguments[2]) else {
            fatal("Error: Invalid amount")
            return nil
        }

        return amount
    }()

    do {
        let data = try ExchangeRateAPI.fetchExchangeRates()
        let xmlDictionary = try XMLDictionaryParser.parse(data: data)
        let exchangeRates = try ExchangeRateParser.parse(xmlDictionary)
        let manager = try ExchangeRateManager(exchangeRates: exchangeRates)

        let exchangeRate = try manager.exchangeRate(for: date)

        print("Date: \(outputDateFormatter.string(from: exchangeRate.date))")

        if let usdToEurString = exchangeRateFormatter.string(from: NSNumber(value: exchangeRate.usdToEur)) {
            print("1 USD = \(usdToEurString) EUR")
        }

        if let eurToUsdString = exchangeRateFormatter.string(from: NSNumber(value: exchangeRate.eurToUsd)) {
            print("1 EUR = \(eurToUsdString) USD")
        }

        if let amount = amount, let amountString = amountFormatter.string(from: NSNumber(value: amount)) {
            let eurAmount = amount * exchangeRate.usdToEur
            let usdAmount = amount * exchangeRate.eurToUsd

            if let usdToEurString = amountFormatter.string(from: NSNumber(value: eurAmount)) {
                print("\(amountString) USD = \(usdToEurString) EUR")
            }

            if let eurToUsdString = amountFormatter.string(from: NSNumber(value: usdAmount)) {
                print("\(amountString) EUR = \(eurToUsdString) USD")
            }
        }
    } catch {
        fatal("Error: \(error)")
    }
}
