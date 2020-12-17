//
//  AdUnitDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Base class for retrieving data from data sources dealing with `AdUnit`s.
 */
class AdUnitDataSource {
    // MARK: - Internal State
    
    /**
     Internally stored data.
     */
    internal var adUnits: [String: [AdUnit]]
    
    /**
     Internally stored alphabetically sorted sections. This is seperated from the
     public getter `sections` to allow overriding `sections`.
     */
    internal var cachedSections: [String]
    
    /**
     Data source sections as human readable text meant for display as section
     headings to the user.
     */
    var sections: [String] {
        return cachedSections
    }
    
    // MARK: - Initializers
    
    /**
     Initializes the data source with an optional plist file.
     - Parameter plistName: Name of a plist file (without the extension) to initialize the
     data source.
     - Parameter bundle: Bundle where the plist file lives.
     */
    required init(plistName: String, bundle: Bundle) {
        guard plistName.count > 0 else {
            adUnits = [:]
            cachedSections = []
            return
        }
        
        adUnits = AdUnitDataSource.openPlist(resourceName: plistName, bundle: bundle) ?? [:]
        cachedSections = adUnits.keys.sorted()
    }
    
    // MARK: - Ad Unit Accessors
    
    /**
     The items at the specified section.
     - Parameter section: Index of the section to retrieve the ad units.
     - Returns: Ad units for the section, or `nil` if out of bounds.
     */
    func items(for section: Int) -> [AdUnit]? {
        guard section >= 0, section < sections.count else {
            return nil
        }
        
        return adUnits[sections[section]]
    }
    
    /**
     Retrieves the ad unit at the specified index path.
     - Parameter indexPath: Ad unit for the given section and index into that section.
     - Returns: The ad unit at the given index path, or `nil` if out of bounds.
     */
    func item(at indexPath: IndexPath) -> AdUnit? {
        guard let adUnits: [AdUnit] = items(for: indexPath.section),
            indexPath.row >= 0, indexPath.row < adUnits.count else {
            return nil
        }
        
        return adUnits[indexPath.row]
    }
    
    /**
     Reloads the data source.
     */
    func reloadData() {
        // By default this does nothing, but may be overridden by subclasses.
    }
}

extension AdUnitDataSource {
    // MARK: - Plist Constants
    
    private struct Constants {
        static let viewControllerClassName: String = "class"
        static let adUnits: String = "ad_units"
    }
    
    // MARK: - Plist
    /**
     Reads in a plist file from the specified bundle with the format
     ```
     {
        "Section Name": {
            "class": "UIViewController class name used to render the ad units within the section",
            "ad_units": [
                { "name": "ad unit name", "id": "ad unit ID", "override_class": "Override UIViewController class name" },
            ]
        }
     }
     ```
     - Parameter resourceName: Name of the plist file without the extension.
     - Parameter bundle: Bundle where the plist can be found.
     - Returns: A dictionary representation of the Plist or `nil`.
     */
    private static func readPlist(resourceName: String, bundle: Bundle) -> [String: Any]? {
        // Attempt to read the sample ads from resourceName.plist and parses the dictionary.
        guard let path = bundle.url(forResource: resourceName, withExtension: "plist"),
            let data = try? Data(contentsOf: path),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                print("Failed to parse \(resourceName).plist")
                return nil
        }
        
        return plist
    }
    
    /**
     Opens and parses an ad unit data source plist into an object oriented representation.
     - Parameter resourceName: Name of the ad unit data source plist file without the extension.
     - Parameter bundle: Bundle where the plist can be found.
     - Returns: The parsed ad unit data source, or `nil`.
     */
    static func openPlist(resourceName: String, bundle: Bundle) -> [String: [AdUnit]]? {
        guard let plist: [String: [String: Any]] = readPlist(resourceName: resourceName, bundle: bundle) as? [String: [String: Any]] else {
            return nil
        }
        
        // Transform the plist format into a data source format.
        var parsedAdUnits: [String: [AdUnit]] = [:]
        for (adFormat, valueDict) in plist {
            guard let defaultViewControllerClassName: String = valueDict[Constants.viewControllerClassName] as? String,
                let adUnitDictionaries: [[String: String]] = valueDict[Constants.adUnits] as? [[String: String]] else {
                    print("Failed to parse \(adFormat) with dictionary \(valueDict)")
                    continue
            }
            
            // Convert all of the ad unit dictionaries into ad units
            let adUnits: [AdUnit] = adUnitDictionaries.compactMap { AdUnit(info: $0, defaultViewControllerClassName: defaultViewControllerClassName) }
            parsedAdUnits[adFormat] = adUnits
        }
        
        return parsedAdUnits
    }
}
