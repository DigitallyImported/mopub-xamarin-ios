//
//  AdapterVersionsMenuDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

class AdapterVersionsMenuDataSource {
    // MARK: - Properties
    
    private enum Item {
        /**
         This cell represents the "no adapters initialized" state.
         */
        case noAdapters
        
        /**
         This cell represents an adpater. The associated value of this case is the name of adapter.
         */
        case adapter(name: String)
        
        /**
         This cell has a Clear Cached Network toggle.
         */
        case clearCachedNetowrksToggle
    }
    
    /**
     This `Item` array represents the cells in the table view.
     */
    private var items: [Item] = []
    
    /**
     Set of adapter names that are currently in an expanded state.
     */
    private var expandedAdapters: Set<String> = Set<String>()
}

extension AdapterVersionsMenuDataSource: MenuDisplayable {
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
        return "Adapters"
    }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell {
        switch items[index] {
        case .noAdapters:
            let cell = tableView.dequeueCellFromNib(cellType: CollapsibleAdapterInfoTableViewCell.self)
            cell.titleLabel.text = "No adapters initialized"
            return cell
            
        case let .adapter(name):
            let cell = tableView.dequeueCellFromNib(cellType: CollapsibleAdapterInfoTableViewCell.self)
            
            // There exist some initialized adapters
            guard let adapter: MPAdapterConfiguration = MoPub.sharedInstance().adapterConfigurationNamed(name) else {
                cell.update(title: name)
                return cell
            }
            
            let isCollapsed: Bool = !expandedAdapters.contains(name)
            cell.update(adapterName: name , info: adapter, isCollapsed: isCollapsed)
            return cell
            
        case .clearCachedNetowrksToggle:
            let cell = tableView.dequeueCellFromNib(cellType: TextAndToggleTableViewCell.self)
            cell.configure(title: "Clear Cached Networks", toggleIsOn: UserDefaults.standard.shouldClearCachedNetworks) { shouldClearCachedNetworks  in
                UserDefaults.standard.shouldClearCachedNetworks = shouldClearCachedNetworks
            }
            return cell
        }
    }
    
    /**
     Query if the menu item is selectable
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Returns: `true` if selectable; `false` otherwise
     */
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool {
        // Selection is only valid if there are adapters present.
        switch items[index] {
        case .noAdapters, .clearCachedNetowrksToggle:
            return false
        case .adapter:
            return true
        }
    }
    
    /**
     Performs an optional selection action for the menu item
     - Parameter indexPath: Menu item indexPath assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Parameter viewController: Presenting view controller
     - Returns: `true` if the menu should collapse when selected; `false` otherwise.
     */
    func didSelect(itemAt indexPath: IndexPath, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Bool {
        switch items[indexPath.row] {
        case .noAdapters:
            return false

        case let .adapter(name):
            // Toggle the expanded state for the adapter
            if expandedAdapters.contains(name) {
                expandedAdapters.remove(name)
            }
            else {
                expandedAdapters.insert(name)
            }
            
            // Notify the table view that it needs to refresh the layout for the selected cell.
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            return false

        case .clearCachedNetowrksToggle:
            return false
        }
    }
    
    /**
     Updates the data source if needed.
     - Returns: `true` update happened; `false` otherwise.
     */
    func updateIfNeeded() -> Bool {
        let previousAdapterNames: [String] = items.compactMap {
            guard case let .adapter(name) = $0 else {
                return nil
            }
            return name
        }
        
        let currentAdapterNames = MoPub.sharedInstance().availableAdapterClassNames()?.sorted() ?? []
        var items: [Item] = currentAdapterNames.isEmpty ? [.noAdapters] : currentAdapterNames.map { .adapter(name: $0) }
        items.append(.clearCachedNetowrksToggle)
        self.items = items
        
        return previousAdapterNames != currentAdapterNames
    }
}
