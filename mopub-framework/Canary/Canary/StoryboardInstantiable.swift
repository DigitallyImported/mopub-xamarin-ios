//
//  StoryboardInstantiable.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 A view controller that can be instantiated from a storyboard.
 
 To add `StoryboardInstantiable` conformance to your custom view controller,
 implement the required `storyboardName`.
 */
protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String? { get }
}

/**
 Provides a default implementation for `storyboardIdentifier` and `storyboardBundle`.
 */
extension StoryboardInstantiable {
    static var storyboardIdentifier: String? { return String(describing: Self.self) }
    static var storyboardBundle: Bundle? { return Bundle(for: Self.self as! AnyClass) }
    
    /**
     Instantiates the view controller from the storyboard.
     - Returns:
     An new instance of the view controller if it exists in the provided storyboard;
     otherwise attempt to instantiate the initial view controller.
     */
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        
        if let storyboardIdentifier = storyboardIdentifier {
            return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
        } else {
            return storyboard.instantiateInitialViewController() as! Self
        }
    }
}
