//
//  AdFormat.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Provides a mapping of ad format to a view controller that can render it.
 */
enum AdFormat: String, CaseIterable {
    /**
     320x50 banner
     */
    case Banner = "Banner"
    
    /**
     Full screen interstitial
     */
    case Interstitial = "Interstitial"
        
    /**
     Medium rectangle
     */
    case MediumRectangle = "MediumRectangle"
    
    /**
     Native ad
     */
    case Native = "Native"
    
    /**
     Native ads rendered in a collection view
     */
    case NativeCollectionPlacer = "NativeCollectionPlacer"
    
    /**
     Native ads rendered in a table view
     */
    case NativeTablePlacer = "NativeTablePlacer"
    
    /**
     Rewarded interstitial
     */
    case Rewarded = "Rewarded"
    
    /**
     Name of the view controller that is capable of rendering the format.
     - Remark: The view controller names come from the storyboard identifiers
     from `AdFormats.storyboard`.
     */
    var renderingViewController: String {
        switch self {
        case .Banner:                   return "BannerAdViewController"
        case .Interstitial:             return "InterstitialAdViewController"
        case .MediumRectangle:          return "MediumRectangleAdViewController"
        case .Native:                   return "NativeAdViewController"
        case .NativeCollectionPlacer:   return "NativeAdCollectionViewController"
        case .NativeTablePlacer:        return "NativeAdTableViewController"
        case .Rewarded:                 return "RewardedAdViewController"
        }
    }
    
    /**
     Storyboard associated with the `renderingViewController` property.
     */
    static let renderingStoryboard: String = "AdFormats"
}
