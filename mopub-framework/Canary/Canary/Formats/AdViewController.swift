//
//  AdViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Protocol that all ad view controllers should conform to.
 */
protocol AdViewController {
    /**
     Ad unit
     */
    var adUnit: AdUnit { get set }
    
    /**
     Instantiates this instance using the a nib file.
     - Parameter adUnit: Ad unit to use with the `AdViewController`.
     */
    static func instantiateFromNib(adUnit: AdUnit) -> Self
}
