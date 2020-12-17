//
//  NativeAdRendererMenuDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

struct NativeAdRendererMenuDataSource {
    enum Item: CaseIterable {
        case changeRendererPreferenceOrder
        
        var cellAccessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .changeRendererPreferenceOrder:
                return .disclosureIndicator
            }
        }
        
        var cellTitle: String {
            switch self {
            case .changeRendererPreferenceOrder:
                return "Change Order"
            }
        }
    }
}

extension NativeAdRendererMenuDataSource: MenuDisplayable {
    /**
     Human-readable title for the menu grouping
     */
    var title: String {
        return "Native Renderer"
    }
    
    /**
     Number of menu items available
     */
    var count: Int {
        return Item.allCases.count
    }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell {
        let item = Item.allCases[index]
        let cell = tableView.dequeueCellFromNib(cellType: BasicMenuTableViewCell.self)
        cell.accessoryType = item.cellAccessoryType
        cell.title.text = item.cellTitle
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
        let sections = [OrderPreferenceViewController.DataSource.Section(header: "Enabled (first match is used)",
                                                                         items: NativeAdRendererManager.shared.enabledRendererClassNames),
                        OrderPreferenceViewController.DataSource.Section(header: "Disabled",
                                                                         items: NativeAdRendererManager.shared.disabledRendererClassNames)]
        let dataSource = OrderPreferenceViewController.DataSource(title: "Native Ad Renderer Preference", sections: sections)
        
        let vc = OrderPreferenceViewController.viewController(dataSource: dataSource, orderChangedHandler: { dataSource in
            if dataSource.sections.count == 2, // enabled and disabled
                dataSource.sections[0].items.contains(MPStaticNativeAdRenderer.className) {
                NativeAdRendererManager.shared.enabledRendererClassNames = dataSource.sections[0].items
                NativeAdRendererManager.shared.disabledRendererClassNames = dataSource.sections[1].items
                return (true, nil)
            } else {
                return (false, "`\(MPStaticNativeAdRenderer.className)` has to be enabled")
            }
        })
        viewController.present(vc, animated: true, completion: nil)
        
        return true
    }
}
