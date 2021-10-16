import Foundation

enum XMLDictionaryParserError: Error {
    case failed
    case elementMismatch
    case missingRoot
}

final class XMLDictionaryParser: NSObject {
    private let parser: XMLParser
    private var parsingError: Error?

    private var currentElement: XMLElement?

    static func parse(data: Data) throws -> XMLElement {
        try Self.init(data: data).parse()
    }

    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() throws -> XMLElement {
        guard parser.parse() else {
            if let parsingError = parsingError {
                throw parsingError
            } else {
                throw XMLDictionaryParserError.failed
            }
        }

        guard let rootElement = currentElement, rootElement.parent == nil else {
            throw XMLDictionaryParserError.missingRoot
        }

        return rootElement
    }
}

final class XMLElement {
    let name: String
    let parent: XMLElement?

    private(set) var children = [String: [XMLElement]]()
    var text = ""
    var attributeDict: [String: String] = [:]

    init(_ parent: XMLElement? = nil, name: String = "") {
        self.parent = parent
        self.name = name
    }

    func push(_ elementName: String) -> XMLElement {
        let childElement = XMLElement(self, name: elementName)

        if let _ = children[elementName] {
            children[elementName]?.append(childElement)
        } else {
            children[elementName] = [childElement]
        }

        return childElement
    }

    func pop(_ elementName: String) throws -> XMLElement? {
        guard elementName == name else {
            throw XMLDictionaryParserError.elementMismatch
        }

        return parent
    }

    subscript(name: String) -> [XMLElement]? {
        children[name]
    }
}

extension XMLDictionaryParser: XMLParserDelegate {

    func parserDidStartDocument(_ parser: XMLParser) {
        currentElement = XMLElement(name: "root")
        parsingError = nil
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = currentElement?.push(elementName)
        currentElement?.attributeDict = attributeDict
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElement?.text += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        do {
            currentElement = try currentElement?.pop(elementName)
        } catch {
            parser.abortParsing()
            parsingError = error
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parsingError = parseError
    }
}
