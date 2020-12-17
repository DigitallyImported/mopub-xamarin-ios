//
//  AdUnit.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Keys to access fields in the dictionary
 */
public struct AdUnitKey {
    static let Id: String = "adUnitId"
    static let Name: String = "name"
    static let Keywords: String = "keywords"
    static let UserDataKeywords: String = "userDataKeywords"
    static let CustomData: String = "custom_data"
    static let OverrideClass: String = "override_class"
    static let Format: String = "format"
    
    /**
     Ad Unit ID to use when the current interface idiom is `pad`
     */
    static let OverridePadId: String = "overridePadAdUnitId"
}

/**
 Represents a displayable ad unit.
 */
public class AdUnit : NSObject, Codable {
    /**
     Ad unit ID as specified in the MoPub dashboard.
     */
    public var id: String
    
    /**
     A human readable name for the ad unit.
     */
    public var name: String

    /**
     An optional comma-delimited string of non-personally identifiable keywords associated with the ad unit.
     */
    public var keywords: String?

    /**
     An optional comma-delimited string of keywords associated with the ad unit.
     */
    public var userDataKeywords: String?
    
    /**
     An optional custom data string to pass along with rewarded ad requests.
     */
    public var customData: String?
    
    /**
     View controller that should be used to render the ad unit. This name is meant to
     initialize a `UIViewController` class from the storyboard.
     */
    public var viewControllerClassName: String
    
    /**
     Initializes an ad unit from a dictionary and a default rendering view controller.
     */
    required public init?(info: [String: String], defaultViewControllerClassName: String) {
        guard let adUnitId = info[AdUnitKey.Id] else {
            return nil
        }
        
        // Determine the iPad version of the Ad Unit ID if available.
        // If no override is available, use the existing Ad Unit ID.
        let isPad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
        let padAdUnitId: String = info[AdUnitKey.OverridePadId] ?? adUnitId

        id = (isPad ? padAdUnitId : adUnitId)
        name = info[AdUnitKey.Name] ?? adUnitId
        keywords = info[AdUnitKey.Keywords]
        userDataKeywords = info[AdUnitKey.UserDataKeywords]
        customData = info[AdUnitKey.CustomData]

        if let overrideViewControllerClassName = info[AdUnitKey.OverrideClass] {
            viewControllerClassName = overrideViewControllerClassName
        }
        else {
            viewControllerClassName = defaultViewControllerClassName
        }
    }
    
    /**
     Attempts to convert a `mopub://` scheme deep link URL into an `AdUnit` object. Returns nil if the URL was not able
     to be converted.
     - Parameter url: MoPub deep link URL
     - Returns: `AdUnit` object or nil if URL was unable to be converted
     */
    convenience public init?(url: URL) {
        // Validate that the URL contains the required query parameters:
        // 1. adUnitId (must be non-nil in value)
        // 2. format (must be a valid format string)
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            queryItems.contains(where: { $0.name == AdUnitKey.Id }),
            let formatString: String = queryItems.filter({ $0.name == AdUnitKey.Format }).first?.value,
            let format = AdFormat(rawValue: formatString) else {
                return nil
        }
        
        // Generate an `AdUnit` from the query parameters and extracted ad format.
        let params: [String: String] = queryItems.reduce(into: [:], { (result, queryItem) in
            result[queryItem.name] = queryItem.value ?? ""
        })
        
        self.init(info: params, defaultViewControllerClassName: format.renderingViewController)
    }
    
    /**
     Attempts to create an `AdUnit` object using an `adUnitId`, `format`, and optionally a `name`. Returns `nil`
     if `AdUnit` object was not able to be created with information provided.
     - Parameter adUnitId: ad unit ID in the form of a string
     - Parameter format: `AdFormat` enum value signifying the ad format
     - Parameter name: optional name in the form of the string. If `nil` is provided, adUnitId will be used instead.
     - Returns: `AdUnit` or `nil`
     */
    convenience init?(adUnitId: String, format: AdFormat, name: String?) {
        var params: [String: String] = [AdUnitKey.Id: adUnitId, AdUnitKey.Format: format.rawValue]
        if let name = name, name.count > 0 {
            params[AdUnitKey.Name] = name
        }
        self.init(info: params, defaultViewControllerClassName: format.renderingViewController)
    }
}

extension AdUnit {
    // MARK: - Filtering
    
    /**
     Queries if the `AdUnit` contains the inputted string. The comparison is case-insensitive.
     - Parameter string: String to search for.
     - Returns: `true` if the `AdUnit` contains the string term; otherwise `false`.
     */
    public func contains(_ string: String) -> Bool {
        let nameContainsFilterTerm: Bool = (name.range(of: string, options: .caseInsensitive) != nil)
        let idContainsFilterTerm: Bool = (id.range(of: string, options: .caseInsensitive) != nil)
        
        return nameContainsFilterTerm || idContainsFilterTerm
    }
}
