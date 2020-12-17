//
//  LogingLevelMenuDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

fileprivate enum LoggingLevelMenuOptions: String {
    case debug = "Debug"
    case info = "Informational"
    case none = "None"
    
    var logLevel: MPBLogLevel {
        switch self {
        case .debug: return MPBLogLevel.debug
        case .info: return MPBLogLevel.info
        case .none: return MPBLogLevel.none
        }
    }
}

class LogingLevelMenuDataSource {
    fileprivate let items: [LoggingLevelMenuOptions] = [.debug, .info, .none]
}

extension LogingLevelMenuDataSource: MenuDisplayable {
    /**
     Number of menu items available
     */
    var count: Int {
        return items.count
    }
    
    /**
     Human-readable title for the menu grouping
     */
    var title: String {
        return "Console Log Level"
    }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: BasicMenuTableViewCell.self)
        let item: LoggingLevelMenuOptions = items[index]
        let currentLogLevel: MPBLogLevel = MPLogging.consoleLogLevel
        
        cell.accessoryType = (currentLogLevel == item.logLevel ? .checkmark : .none)
        cell.title.text = item.rawValue
        
        return cell
    }
    
    /**
     Query if the menu item is selectable
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Returns: `true` if selectable; `false` otherwise
     */
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool {
        return true
    }
    
    /**
     Performs an optional selection action for the menu item
     - Parameter indexPath: Menu item indexPath assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Parameter viewController: Presenting view controller
     - Returns: `true` if the menu should collapse when selected; `false` otherwise.
     */
    func didSelect(itemAt indexPath: IndexPath, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Bool {
        let item: LoggingLevelMenuOptions = items[indexPath.row]
        MPLogging.consoleLogLevel = item.logLevel
        
        tableView.reloadData()
        return true
    }
}
