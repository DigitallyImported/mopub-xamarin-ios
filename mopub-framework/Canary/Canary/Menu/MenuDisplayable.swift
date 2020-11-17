//
//  MenuDisplayable.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

protocol MenuDisplayable {
    /**
     Number of menu items available
     */
    var count: Int { get }
    
    /**
     Human-readable title for the menu grouping
     */
    var title: String { get }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell
    
    /**
     Query if the menu item is selectable
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Returns: `true` if selectable; `false` otherwise
     */
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool
    
    /**
     Performs an optional selection action for the menu item
     - Parameter indexPath: Menu item indexPath assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Parameter viewController: Presenting view controller
     - Returns: `true` if the menu should collapse when selected; `false` otherwise.
     */
    func didSelect(itemAt indexPath: IndexPath, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Bool
    
    /**
     Updates the data source if needed.
     - Returns: `true` update happened; `false` otherwise.
     */
    func updateIfNeeded() -> Bool
}

extension MenuDisplayable {
    // MARK: - Default implementations
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool {
        return false
    }
    
    func didSelect(itemAt indexPath: IndexPath, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Bool {
        return true
    }
    
    func updateIfNeeded() -> Bool {
        return false
    }
}
