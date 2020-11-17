//
//  MPConsentStatus+Description.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

public extension MPConsentStatus {
    /**
     Human readable description of the status.
     */
    var description: String {
        switch self {
        case .consented: return "Consented"
        case .denied: return "Denied"
        case .doNotTrack: return "Do not track"
        case .potentialWhitelist: return "Potentially whitelisted"
        case .unknown: return "Unknown"
        @unknown default: fatalError("\(#function) unexpected enum case")
        }
    }
}
