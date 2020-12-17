//
//  MPNativeAdRendererConfiguration+Utilities.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

extension MPNativeAdRendererConfiguration {
    var rendererClassName: String {
        // If `rendererClass` is not unwrapped, the class name is wrapped by "Optional(...)" undesirably
        guard let rendererClass = rendererClass else {
            assertionFailure("\(#function) rendererClass is nil")
            return ""
        }
        return String(describing: rendererClass.self)
    }
}

// Conform to `StringKeyable` to make `MPNativeAdRendererConfiguration` sortable.
extension MPNativeAdRendererConfiguration: StringKeyable {
    var key: String {
        return rendererClassName
    }
}
