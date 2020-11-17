//
//  NativeAdRendererManagerTests.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import Canary

final class NativeAdRendererManagerTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var nativeAdRendererManager: NativeAdRendererManager!
    
    private let defaultRenderers = ["MOPUBNativeVideoAdRenderer",
                                    "MPGoogleAdMobNativeRenderer",
                                    "FacebookNativeAdRenderer",
                                    "FlurryNativeVideoAdRenderer",
                                    "MPStaticNativeAdRenderer"]
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        nativeAdRendererManager = NativeAdRendererManager(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        nativeAdRendererManager = nil
    }
    
    /**
     This test expects all default renderers to be enabled.
     */
    func testDefaultEnabledRenderers() {
        XCTAssertEqual(nativeAdRendererManager.enabledRendererClassNames, defaultRenderers)
    }
    
    /**
     This test expects all default renderers to be disabled.
     */
    func testDefaultDisabledRenderers() {
        XCTAssertEqual(nativeAdRendererManager.disabledRendererClassNames, [])
    }
    
    /**
     Test the manager is returning expected renderer configurations
     */
    func testDefaultEnabledRenderersConfigurations() {
        XCTAssertEqual(nativeAdRendererManager.enabledRendererConfigurations.map { $0.rendererClassName }, defaultRenderers)
    }
    
    /**
     Test reading and writing `NativeAdRendererManager.enabledRendererClassNames` and
     `NativeAdRendererManager.disabledRendererClassNames`.
     */
    func testReadWriteRenderers() {
        var enabledRenderers = defaultRenderers
        var disabledRenderers = [String]()
        
        // first pass: disable renderers one by one
        repeat {
            nativeAdRendererManager.disabledRendererClassNames = disabledRenderers
            XCTAssertEqual(nativeAdRendererManager.disabledRendererClassNames, disabledRenderers)
            
            nativeAdRendererManager.enabledRendererClassNames = enabledRenderers
            XCTAssertEqual(nativeAdRendererManager.enabledRendererClassNames, enabledRenderers)
            XCTAssertEqual(nativeAdRendererManager.enabledRendererConfigurations.map { $0.rendererClassName }, enabledRenderers)
            
            disabledRenderers.append(enabledRenderers.removeLast())
        } while !enabledRenderers.isEmpty
        
        // second pass: enable renderers one by one
        repeat {
            nativeAdRendererManager.disabledRendererClassNames = disabledRenderers
            XCTAssertEqual(nativeAdRendererManager.disabledRendererClassNames, disabledRenderers)
            
            nativeAdRendererManager.enabledRendererClassNames = enabledRenderers
            XCTAssertEqual(nativeAdRendererManager.enabledRendererClassNames, enabledRenderers)
            XCTAssertEqual(nativeAdRendererManager.enabledRendererConfigurations.map { $0.rendererClassName }, enabledRenderers)
            
            enabledRenderers.append(disabledRenderers.removeLast())
        } while !disabledRenderers.isEmpty
    }
}
