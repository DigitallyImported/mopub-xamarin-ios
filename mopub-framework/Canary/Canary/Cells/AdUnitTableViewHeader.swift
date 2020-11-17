//
//  AdUnitTableViewHeader.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class AdUnitTableViewHeader: UITableViewHeaderFooterView {
    // Outlets from `AdUnitTableViewHeader.xib`
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    /**
     Constant representing a default reuseable table header ID.
     */
    static let reuseId: String = "AdUnitTableViewHeader"
    
    /**
     Registers this table header with a given table using the `reuseId` constant.
     - Parameter tableView: A valid table to register this header.
     */
    class func register(with tableView: UITableView) -> Void {
        let nib = UINib(nibName: reuseId, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseId)
    }
    
    /**
     Updates the contents of the header.
     - Parameter title: Title of the header.
     */
    func refresh(title: String) -> Void {
        titleLabel.text = title
        setNeedsLayout()
    }
}
