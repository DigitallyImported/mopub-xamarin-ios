//
//  Array+Sort.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Conforming objects can provided a @c String as a key for various purpose, such as making a key
 value pair for dictionary.
 */
protocol StringKeyable {
    var key: String { get }
}

extension Sequence where Element == StringKeyable {
    /**
     Given each `Element` as `StringKeyable` can provided a `key`, return a sorted array of `Element`
     that is sorted in the same order as the provided `keys` array.
     
     * Note 1: If the source `Sequence` has extra elements that are not in the reference `keys` array,
     the extra elements are appended to the end with undefined order.
     
     * Note 2: The returned array eliminates duplicate elements in the source `Sequence`, if there is
     any duplicate.
     
     - Parameter keys: An array of keys that represents the expected sort order
     - Returns: An sorted array of all original elements
     */
    func sorted<Element: StringKeyable>(inTheSameOrderAs keys:[String]) -> [Element] {
        var dictionary = [String: Element]()
        forEach {
            guard let element = $0 as? Element else {
                assertionFailure("\(#function) element [\($0)] is not in the expected type \(Element.self)")
                return
            }
            dictionary[$0.key] = element
        }
        
        var result = [Element]()
        keys.forEach {
            guard let value = dictionary[$0] else {
                return
            }
            result.append(value)
            dictionary.removeValue(forKey: $0)
        }
        result.append(contentsOf: dictionary.values) // for remaining values not in `orderedKeys`
        
        return result
    }
}
