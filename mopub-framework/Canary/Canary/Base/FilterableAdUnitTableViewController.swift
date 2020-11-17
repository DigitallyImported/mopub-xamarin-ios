//
//  FilterableAdUnitTableViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class FilterableAdUnitTableViewController: AdUnitTableViewController {
    // MARK: - Internal State
    
    /**
     Assumes that `dataSource` will be in `viewDidLoad()` before use.
     */
    private var dataSource: FilteredAdUnitDataSource!
    
    /**
     Search controller used to filter the data source.
     */
    private var searchController: UISearchController!
    
    // MARK: - Initialization
    
    /**
     Initializes the view controller's data source. This must be performed before
     `viewDidLoad()` is called.
     - Parameter dataSource: Data source for the view controller.
     */
    func initialize(with dataSource: FilteredAdUnitDataSource) {
        self.dataSource = dataSource
        super.initialize(with: dataSource)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // Load super view
        super.viewDidLoad()
        
        // Add the search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Filter Ads"
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        // Definte presentation context so that the search bar does not remain
        // on the screen if the user navigates to another view controller
        // while the `UISearchController` is active.
        definesPresentationContext = true
    }
}

extension FilterableAdUnitTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        dataSource.filter = searchController.searchBar.text
        tableView.reloadData()
    }
}
