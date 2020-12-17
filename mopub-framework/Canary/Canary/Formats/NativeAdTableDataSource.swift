//
//  NativeAdTableDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class NativeAdTableDataSource: BaseNativeAdDataSource {
    // MARK: - Ad Properties
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
        
    // MARK: - Fake Table Data
    
    /**
     Table data is all font family names.
     */
    lazy var data: [String] = {
        return UIFont.familyNames.sorted()
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
    var targetting: MPNativeAdRequestTargeting {
        let target: MPNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        target.desiredAssets = Set(arrayLiteral: kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, kAdIconImageViewKey, kAdMainMediaViewKey)
        target.keywords = adUnit.keywords
        target.userDataKeywords = adUnit.userDataKeywords
        
        return target
    }
}
