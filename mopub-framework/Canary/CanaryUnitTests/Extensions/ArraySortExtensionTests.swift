//
//  ArraySortExtensionTests.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import Canary

// Test helper extension
extension String: StringKeyable {
    public var key: String {
        return self
    }
}

final class ArraySortExtensionTests: XCTestCase {
    let referenceKeys = ["1", "2", "3", "4", "5"]
    
    /**
     Test sorting arrays with the same elements.
     */
    func testSortingArrayWithSameElementsAsReferenceArray() {
        let arraysToSort = [["1", "2", "3", "4", "5"],
                            ["3", "1", "2", "4", "5"],
                            ["5", "4", "1", "3", "2"],
                            ["4", "5", "1", "2", "3"]]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertEqual(result, referenceKeys)
        }
    }
    
    /**
     Test sorting an empty array.
     */
    func testSortingEmptyArray() {
        XCTAssertTrue(([StringKeyable]().sorted(inTheSameOrderAs: referenceKeys) as [String]).isEmpty)
    }
    
    /**
     Test sorting arrays with empty reference array.
     */
    func testSortingWithEmptyReferenceArray() {
        let arraysToSort = [["1", "2", "3", "4", "5"],
                            ["3", "1", "2", "4", "5"],
                            ["5", "4", "1", "3", "2"],
                            ["4", "5", "1", "2", "3"]]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: [])
            XCTAssertEqual(Set(result).count, 5) // order is undefined, so only test the count
        }
    }
    
    /**
     Test sorting arrays with one extra element that is not in the reference array.
     */
    func testSortingArrayWithOneUnexpectedElementThanReferenceArray() {
        let extraElement = "extra"
        let arraysToSort = [["1", "2", "3", "4", "5", extraElement],
                            ["3", "1", "2", extraElement, "4", "5"],
                            [extraElement, "5", "4", "1", "3", "2"]]
        let expectedResult = referenceKeys + [extraElement] // the extra one is expected to be at the end
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    /**
     Test sorting arrays with two extra elements that are not in the reference array.
     */
    func testSortingArrayWithTwoUnexpectedElementsThanReferenceArray() {
        let extraElement1 = "extra1"
        let extraElement2 = "extra2"
        let arraysToSort = [[extraElement1, "1", "2", "3", "4", "5", extraElement2],
                            [extraElement2, "3", "1", "2", extraElement1, "4", "5"],
                            ["5", "4", extraElement2, "1", "3", "2", extraElement1]]
        
        // The order of unexpected extra elements is undefined (and thus random)
        let possibleResult1 = referenceKeys + [extraElement1, extraElement2]
        let possibleResult2 = referenceKeys + [extraElement2, extraElement1]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertTrue(result == possibleResult1 || result == possibleResult2)
        }
    }
    
    /**
     Test sorting arrays with less element than the reference array.
     */
    func testSortingArrayWithLessElementsThanReferenceArray() {
        let arraysToSort = [["1", "3", "5"],
                            ["3", "1", "5"],
                            ["5", "1", "3"],
                            ["1", "5", "3"]]
        let expectedResult = ["1", "3", "5"]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    /**
     Test sorting arrays that are mixed with unexpected elements, and with less element than the reference array.
     */
    func testSortingArrayMixedWithUnexpectedElementsAndWithLessElementsThanReferenceArray() {
        let extraElement1 = "extra1"
        let extraElement2 = "extra2"
        let arraysToSort = [[extraElement1, "1", "3", "5", extraElement2],
                            ["3", extraElement1, "1", extraElement2, "5"],
                            [extraElement1, "5", extraElement2, "1", "3"],
                            ["1", extraElement1, "5", "3", extraElement2]]
        
        // The order of unexpected extra elements is undefined (and thus random)
        let possibleResult1 = ["1", "3", "5"] + [extraElement1, extraElement2]
        let possibleResult2 = ["1", "3", "5"] + [extraElement2, extraElement1]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertTrue(result == possibleResult1 || result == possibleResult2)
        }
    }
    
    /**
     Test sorting arrays that have duplicate elements in it.
     */
    func testSortingArrayWithDuplicateElementsReferenceArray() {
        let arraysToSort = [["1", "2", "3", "4", "5", "1", "2", "3", "4", "5"],
                            ["3", "1", "2", "4", "5", "3", "1", "2", "4", "5"],
                            ["5", "4", "1", "3", "2", "1", "1", "1", "1", "1"],
                            ["1", "1", "1", "1", "1", "4", "5", "1", "2", "3"]]
        let expectedResult = ["1", "2", "3", "4", "5"]
        
        arraysToSort.forEach {
            let result: [String] = ($0 as [StringKeyable]).sorted(inTheSameOrderAs: referenceKeys)
            XCTAssertEqual(result, expectedResult)
        }
    }
}
