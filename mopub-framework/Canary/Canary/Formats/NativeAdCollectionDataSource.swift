//
//  NativeAdCollectionDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import LoremIpsum
import MoPub
import UIKit

class NativeAdCollectionDataSource: BaseNativeAdDataSource {
    // MARK: - Ad Properties
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     The ad unit information sections available for the ad.
     */
    let information: [AdInformation] = [.id, .keywords, .userDataKeywords]
    
    // MARK: - Fake Table Data
    
    /**
     Collection data.
     */
    lazy var data: [(name: String, tweet: String, color: UIColor)] = {
        var data: [(name: String, tweet: String, color: UIColor)] = []
        for index in 1...100 {
            let name = LoremIpsum.name()!
            let tweet = LoremIpsum.tweet()!
            let color = UIColor.random
            data.append((name: name, tweet: tweet, color: color))
        }
        
        return data
    }()
    
    // MARK: - Initialization
    
    /**
     Initializes the Native ad table data source.
     - Parameter adUnit: Native ad unit.
     */
    init(adUnit: AdUnit) {
        super.init()
        self.adUnit = adUnit
    }
    
    // MARK: - Targetting
    
    /**
     Computed native ad targetting settings.
     */
    var targeting: MPNativeAdRequestTargeting {
        let target: MPNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        target.desiredAssets = Set(arrayLiteral: kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, kAdIconImageViewKey, kAdMainMediaViewKey)
        target.keywords = adUnit.keywords
        target.userDataKeywords = adUnit.userDataKeywords
        
        return target
    }
}
