//
//  NSObject+Utility.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

extension NSObject {
    /**
     A string that represents the name of the class.
     */
    static var className: String {
        return String(describing: self)
    }
}
