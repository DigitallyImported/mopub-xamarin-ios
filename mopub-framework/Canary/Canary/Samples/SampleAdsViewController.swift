//
//  SampleAdsViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class SampleAdsViewController: AdUnitTableViewController {
    // MARK: - Constants
    
    struct Constants {
        static let sampleAdsPlist: String = "SampleAds"
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // Initialize the data source before invoking the base class's
        // `viewDidLoad()` method.
        let dataSource: AdUnitDataSource = AdUnitDataSource(plistName: Constants.sampleAdsPlist, bundle: Bundle.main)
        super.initialize(with: dataSource)
        
        super.viewDidLoad()
    }
}
