import Foundation

extension Array {

    func groupBy<U>(_ elementGroupLookup: @escaping (Element) -> U?) -> [U: [Element]] {
        reduce(into: [U: [Element]](), { result, element in
            guard let elementGroup = elementGroupLookup(element) else { return }
            result[elementGroup] = result[elementGroup, default: []] + CollectionOfOne(element)
        })
    }
}
