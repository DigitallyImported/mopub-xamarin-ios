//
//  BannerAdViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

@objc(BannerAdViewController)
class BannerAdViewController: AdTableViewController {
    // MARK: - Properties
    
    override var adUnit: AdUnit {
        get {
            return dataSource.adUnit
        }
        set {
            // Create a new banner specific data source with the new ad unit.
            // We are requesting the maximum desired banner size.
            let bannerDataSource: BannerAdDataSource = BannerAdDataSource(adUnit: newValue, bannerSize: kMPPresetMaxAdSize250Height)
            dataSource = bannerDataSource
        }
    }
    
    /**
     Inline ad height constraint. This should only be set by `viewDidLoad()` and `viewDidLayoutSubviews()` if a
     table header view exists.
     */
    private var heightConstraint: NSLayoutConstraint? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // Past this point, the data source must be valid.
        guard dataSource != nil else {
            return
        }
        
        // Finish setting up the data source
        dataSource.delegate = self
        
        // Invoke the super class to finish loading the view.
        super.viewDidLoad()
        
        // Fix the banner height so that Auto Layout will correctly resize the table header.
        if let header = tableView.tableHeaderView {
            // Initialize the height constraint to the minimum supported banner height
            heightConstraint = header.heightAnchor.constraint(equalToConstant: kMPPresetMaxAdSize50Height.height)
            
            let constraints = [
                header.widthAnchor.constraint(equalTo: tableView.widthAnchor),
                header.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                header.topAnchor.constraint(equalTo: tableView.topAnchor),
                heightConstraint!
            ]
            NSLayoutConstraint.activate(constraints)
            tableView.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // No table header to update
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        // Update the height constraint to match the height of the inline ad
        if let constraint = heightConstraint {
            constraint.constant = headerView.frame.height
        }
        // Create a new height constraint
        else {
            heightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerView.frame.height)
            heightConstraint?.isActive = true
        }
        
        tableView.layoutIfNeeded()
    }
}

extension BannerAdViewController: AdDataSourcePresentationDelegate {
    // MARK: - AdDataSourcePresentationDelegate
    
    /**
     View controller used to present models (either the ad itself or any click through destination).
     */
    var adPresentationViewController: UIViewController? {
        return self
    }
    
    /**
     Table view used to present the contents of the data source.
     */
    var adPresentationTableView: UITableView {
        return tableView
    }
}
