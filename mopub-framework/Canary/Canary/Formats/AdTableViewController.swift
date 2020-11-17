//
//  AdTableViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Table sections.
 */
fileprivate enum AdTableSection: Int, CaseIterable {
    case information = 0
    case actions     = 1
    case status      = 2
}

@objc(AdTableViewController)
class AdTableViewController: UIViewController, AdViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    /**
     The data source should be initialized by subclasses, and must be set before `viewDidLoad()`.
     */
    internal var dataSource: AdDataSource!
    
    // MARK: - AdViewController
    
    /**
     Ad unit
     */
    var adUnit: AdUnit {
        get {
            return dataSource.adUnit
        }
        set {
            // Subclasses should set `dataSource` to their specific type of data source.
        }
    }
    
    /**
     Instantiates this instance using the a nib file.
     - Parameter adUnit: Ad unit to use with the `AdViewController`.
     */
    static func instantiateFromNib(adUnit: AdUnit) -> Self {
        // The reason for the generic method in this static, is to preserve
        // the original type of the caller when instantiating an instance.
        // For example: If class A is a subclass of AdTableViewController,
        // this will return an initialized instance of type A.
        // Without the generics, this will return type AdTableViewController.
        func instantiateFromNib<T: UIViewController>(_ viewType: T.Type) -> T {
            return T.init(nibName: "AdTableViewController", bundle: nil)
        }
        
        let instance = instantiateFromNib(self)
        instance.adUnit = adUnit
        
        return instance
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---------------------------------------------------------------
        // It is assumed that at this point, `dataSource` is initialized
        // and ready to be used.
        // ---------------------------------------------------------------
        
        // Reduce the spacing between sections
        tableView.sectionHeaderHeight = 2.0;
        tableView.sectionFooterHeight = 0.0;
        
        // Register the table delegate handlers
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register table cells
        AdActionsTableViewCell.register(with: tableView)
        AdUnitTableViewCell.register(with: tableView)
        StatusTableViewCell.register(with: tableView)
        TextEntryTableViewCell.register(with: tableView)
        
        // The ad view will be attached to the table header if available.
        tableView.tableHeaderView = dataSource.adContainerView
        
        // Update the title
        title = dataSource.adUnit.name
        
        // Add split view controller collapse button if applicable
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            // Resize the table header when rotating
            self?.resizeTableHeaderView()
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    /**
     Called when the user click on the view.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    /**
     Resizes the table header view which contains the ad view.
     */
    private func resizeTableHeaderView() {
        guard let header = tableView.tableHeaderView else {
            return
        }
        
        let size = header.sizeFitting(view: tableView)
        header.frame = CGRect(origin: .zero, size: size)
        tableView.tableHeaderView = header
    }
}

extension AdTableViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AdTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = AdTableSection(rawValue: section) else {
            return 0
        }
        
        switch tableSection {
        case .information: return dataSource.information.count
        case .actions: return 1
        case .status: return dataSource.events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = AdTableSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch tableSection {
        case .information: return self.tableView(tableView, informationCellForRowAt: indexPath)
        case .actions: return self.tableView(tableView, actionCellForRowAt: indexPath)
        case .status: return self.tableView(tableView, eventStatusCellForRowAt: indexPath)
        }
    }
    
    // MARK: - Ad Unit Information Cells
    
    /**
     Retrieves a table cell that displays ad unit information.
     */
    func tableView(_ tableView: UITableView, informationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoType = dataSource.information[indexPath.row]
        switch infoType {
        case .id: return self.tableView(tableView, adUnitIdCellForRowAt:indexPath)
        case .keywords: return self.tableView(tableView, keywordsCellForRowAt:indexPath)
        case .userDataKeywords: return self.tableView(tableView, userDataKeywordsCellForRowAt:indexPath)
        case .customData: return self.tableView(tableView, customDataCellForRowAt:indexPath)
        }
    }
    
    /**
     Retrieves a table cell that displays the ad unit ID.
     */
    func tableView(_ tableView: UITableView, adUnitIdCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: AdUnitTableViewCell.self)
        cell.accessibilityIdentifier = dataSource.adUnit.id
        cell.accessoryType = .none
        cell.adUnitId.text = dataSource.adUnit.id
        cell.name.text = "ID"
        
        return cell
    }
    
    /**
     Retrieves a table cell that displays the keywords of the ad unit.
     */
    func tableView(_ tableView: UITableView, keywordsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: TextEntryTableViewCell.self)
        cell.refresh(title: "Keywords", text: dataSource.adUnit.keywords) { [weak self] (keywords: String?) in
            self?.dataSource.adUnit.keywords = keywords
        }
        
        cell.accessibilityIdentifier = dataSource.adUnit.keywords
        return cell
    }
    
    /**
     Retrieves a table cell that displays the user data keywords of the ad unit.
     */
    func tableView(_ tableView: UITableView, userDataKeywordsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: TextEntryTableViewCell.self)
        cell.refresh(title: "User Data Keywords", text: dataSource.adUnit.userDataKeywords) { [weak self] (piiKeywords: String?) in
            self?.dataSource.adUnit.userDataKeywords = piiKeywords
        }
        
        cell.accessibilityIdentifier = dataSource.adUnit.userDataKeywords
        return cell
    }
    
    /**
     Retrieves a table cell that displays the custom data for the ad unit.
     */
    func tableView(_ tableView: UITableView, customDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: TextEntryTableViewCell.self)
        cell.refresh(title: "Custom Data", text: dataSource.adUnit.customData) { [weak self] (customData: String?) in
            self?.dataSource.adUnit.customData = customData
        }
        
        cell.accessibilityIdentifier = dataSource.adUnit.customData
        return cell
    }
    
    // MARK: - Action Cells
    
    /**
     Retrieves the ad unit actions cell.
     */
    func tableView(_ tableView: UITableView, actionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: AdActionsTableViewCell.self)
        let isAdLoading = dataSource.isAdLoading
        let loadHandler = dataSource.actionHandlers[.load]
        let showHandler = dataSource.actionHandlers[.show]
        let showEnabled = dataSource.isAdLoaded
        cell.refresh(isAdLoading: isAdLoading, loadAdHandler: loadHandler, showAdHandler: showHandler, showButtonEnabled: showEnabled)
        return cell
    }
    
    // MARK: - Status Cells
    
    /**
     Retrieves the event status cell and updates it with the information found at the `indexPath` in
     `dataSource`.
     */
    func tableView(_ tableView: UITableView, eventStatusCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: StatusTableViewCell.self)
        
        // Update the state of the cell
        let event = dataSource.events[indexPath.row]
        let status = dataSource.status(for: event)
        cell.update(status: status.title, error: status.message, isHighlighted: status.isHighlighted)
        
        cell.accessibilityIdentifier = status.title
        return cell
    }
}

extension AdTableViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
