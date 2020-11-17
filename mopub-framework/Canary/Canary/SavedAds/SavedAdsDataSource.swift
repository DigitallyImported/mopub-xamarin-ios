//
//  SavedAdsDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Saved ad units data source
 */
final class SavedAdsDataSource: AdUnitDataSource {
    private let savedAdSectionTitle = "Saved Ads"
    
    // MARK: - Overrides
    
    /**
     Initializes the data source with an optional plist file.
     - Parameter plistName: Name of a plist file (without the extension) to initialize the
     data source.
     - Parameter bundle: Bundle where the plist file lives.
     */
    required init(plistName: String = "", bundle: Bundle = Bundle.main) {
        super.init(plistName: plistName, bundle: bundle)
        self.adUnits = [savedAdSectionTitle: SavedAdsManager.sharedInstance.savedAds]
    }
    
    /**
     Reloads the data source.
     */
    override func reloadData() {
        self.adUnits = [savedAdSectionTitle: SavedAdsManager.sharedInstance.savedAds]
    }
    
    /**
     Data source sections as human readable text meant for display as section headings to the user.
     */
    override var sections: [String] {
        return [savedAdSectionTitle]
    }
}
