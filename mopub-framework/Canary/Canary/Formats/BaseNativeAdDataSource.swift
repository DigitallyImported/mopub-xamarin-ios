//
//  BaseNativeAdDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

/**
 Base native ad data source to share ad rendering configurations
 */
class BaseNativeAdDataSource: NSObject {
    /**
     Ad renderer configurations.
     */
    var rendererConfigurations: [MPNativeAdRendererConfiguration] {
        return NativeAdRendererManager.shared.enabledRendererConfigurations
    }
}
