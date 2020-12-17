//
//  SavedAdsManagerTests.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import Canary

final class CanaryUnitTests: XCTestCase {
    private var savedAdsManager: SavedAdsManager!
    private var userDefaults: UserDefaults!
    private var notificationToken: Notification.Token?
    private let sampleAdUnits = [AdUnit(url: URL(string: "mopub://load?adUnitId=100&format=Banner&name=Ad0")!)!,
                                 AdUnit(url: URL(string: "mopub://load?adUnitId=101&format=Banner&name=Ad1")!)!,
                                 AdUnit(url: URL(string: "mopub://load?adUnitId=102&format=Banner&name=Ad2")!)!]
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        savedAdsManager = SavedAdsManager(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        savedAdsManager = nil
    }
    
    /**
     This test adds all sample ads to `savedAdsManager` and verify the result after each addition,
     and then removes all sample ads and verify the result after each deletion. In addition of
     testing the source of truth `savedAdsManager.savedAds`, this test also verify the
     `SavedAdsManager.DataUpdatedNotification` posted after each addition and deletion.
     */
    func testAddAndRemoveSavedAds() {
        var notificationCount = 0
        
        // test adding ads
        sampleAdUnits.enumerated().forEach { (index, adUnit) in
            let verifyAddition = {
                XCTAssertEqual(index + 1, self.savedAdsManager.savedAds.count)
                XCTAssertTrue(self.savedAdsManager.savedAds.contains(adUnit))
            }
            notificationToken = SavedAdsManager.DataUpdatedNotification.addObserver { _ in
                verifyAddition()
                notificationCount += 1
            }
            
            savedAdsManager.addSavedAd(adUnit: adUnit)
            verifyAddition()
            notificationToken = nil
        }
        XCTAssertEqual(notificationCount, sampleAdUnits.count) // number of additions
        
        // test deleting ads
        sampleAdUnits.enumerated().forEach { (index, adUnit) in
            let verifyDeletion = {
                XCTAssertEqual(index + 1, self.sampleAdUnits.count - self.savedAdsManager.savedAds.count)
                XCTAssertFalse(self.savedAdsManager.savedAds.contains(adUnit))
            }
            notificationToken = SavedAdsManager.DataUpdatedNotification.addObserver { _ in
                verifyDeletion()
                notificationCount += 1
            }
            
            savedAdsManager.removeSavedAd(adUnit: adUnit)
            verifyDeletion()
            notificationToken = nil
        }
        XCTAssertEqual(notificationCount, sampleAdUnits.count * 2) // number of additions + deletions
    }
    
    /**
     This test is to verify duplicate ads are impossible.
     */
    func testAddDuplicateAd() {
        for _ in 0...1 { // repeat once
            sampleAdUnits.forEach {
                savedAdsManager.addSavedAd(adUnit: $0)
            }
            XCTAssertEqual(sampleAdUnits.count, savedAdsManager.savedAds.count)
        }
    }
    
    /**
     This test is to verify removing ads that are not saved would not cause any trouble.
     */
    func testRemoveNotSavedAd() {
        sampleAdUnits.forEach {
            savedAdsManager.removeSavedAd(adUnit: $0)
        }
        XCTAssertEqual(0, savedAdsManager.savedAds.count)
    }
}
