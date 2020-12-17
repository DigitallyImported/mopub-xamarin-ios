//
//  TableViewCellRegisterable.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Provides a standard way of registering a `UITableViewCell` with associated Nib with a `UITableView`.
 
 Note: The default implementation of `register(with tableView:)` expects the cell to have a
 corresponding nib file that has the file name that matches the class name. The class name is also
 provided to the table view as reuse identifier when registring the cell.
 */
protocol TableViewCellRegisterable: UITableViewCell {
    /**
     Registers this table cell with a given table using `className`.
     - Parameter tableView: A valid table to register this cell.
     */
    static func register(with tableView: UITableView)
}

extension TableViewCellRegisterable {
    static func register(with tableView: UITableView) {
        let nib = UINib(nibName: className, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: className)
    }
}
