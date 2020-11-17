//
//  FilteredAdUnitDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Class for retrieving data from data sources dealing with `AdUnit`s with
 filtering capabilities.
 */
class FilteredAdUnitDataSource: AdUnitDataSource {
    // MARK: - Internal State
    
    /**
     Currently filtered AdUnits
     */
    private var filteredAdUnits: [String: [AdUnit]] = [:]
    
    /**
     Currently filtered sections
     */
    private var filteredSections: [String] = []
    
    // MARK: - Properties
    
    /**
     Optional text used filter the data source.
     */
    var filter: String? = nil {
        didSet {
            // Trim leading and trailing whitespaces and newlines out of the filter
            filter = filter?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // No filtering in effect
            guard let filter = filter, filter.count > 0 else {
                filteredAdUnits = [:]
                filteredSections = []
                return
            }
            
            // Update the filtered sections.
            // Filtering rules:
            // 1. If a section includes the filter term, all values in the section will be available.
            // 2. If a section does not include the filter term, only values that match the
            //    filter term will be included for that section.
            filteredAdUnits = [:]
            for (key, value) in adUnits {
                // If a section includes the filter term, all values in the section will be available.
                if key.range(of: filter, options: .caseInsensitive) != nil {
                    filteredAdUnits[key] = value
                    continue
                }
                    
                // If a section does not include the filter term, only values that match the
                // filter term will be included for that section.
                let filteredValues: [AdUnit] = value.filter({ return $0.contains(filter) })
                if filteredValues.count > 0 {
                    filteredAdUnits[key] = filteredValues
                }
            }
            
            filteredSections = filteredAdUnits.keys.sorted()
        }
    }
    
    // MARK: - Initializers
    
    /**
     Initializes the data source with an optional plist file.
     - Parameter plistName: Name of a plist file (without the extension) to initialize the
     data source.
     - Parameter bundle: Bundle where the plist file lives.
     */
    required init(plistName: String, bundle: Bundle) {
        super.init(plistName: plistName, bundle: bundle)
    }
    
    // MARK: - Overrides
    
    /**
     Data source sections as human readable text meant for display as section
     headings to the user.
     */
    override var sections: [String] {
        guard let filter = filter, filter.count > 0 else {
            return cachedSections
        }
        
        return filteredSections
    }
    
    /**
     The items at the specified section.
     - Parameter section: Index of the section to retrieve the ad units.
     - Returns: Ad units for the section, or `nil` if out of bounds.
     */
    override func items(for section: Int) -> [AdUnit]? {
        guard let filter = filter, filter.count > 0 else {
            return super.items(for: section)
        }
        
        guard section >= 0, section < sections.count else {
            return nil
        }
        
        return filteredAdUnits[sections[section]]
    }
}
