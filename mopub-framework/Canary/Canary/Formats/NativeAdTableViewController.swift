//
//  NativeAdTableViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

@objc(NativeAdTableViewController)
class NativeAdTableViewController: UIViewController, AdViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Data Sources

    /**
     Data Source
     */
    fileprivate var dataSource: NativeAdTableDataSource!
    
    /**
     Table placer
     */
    private var tablePlacer: MPTableViewAdPlacer!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---------------------------------------------------------------
        // It is assumed that at this point, `dataSource` is initialized
        // and ready to be used.
        // ---------------------------------------------------------------
        
        // Construct the table placer
        tablePlacer = MPTableViewAdPlacer(tableView: tableView, viewController: self, rendererConfigurations: dataSource.rendererConfigurations)
        
        // Register the table cells
        StatusTableViewCell.register(with: tableView)
        
        // Assign the delegates
        tableView.mp_setDataSource(self)
        tableView.mp_setDelegate(self)
        
        // Load the ads
        loadAds()
        
        // Set the title
        title = adUnit.name
    }
    
    // MARK: - DisplayableAd
    
    /**
     Ad unit
     */
    var adUnit: AdUnit {
        get {
            return dataSource.adUnit
        }
        set {
            dataSource = NativeAdTableDataSource(adUnit: newValue)
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
            return T.init(nibName: "NativeAdTableViewController", bundle: nil)
        }
        
        let instance = instantiateFromNib(self)
        instance.adUnit = adUnit
        
        return instance
    }
    
    // MARK: - Ad Loading
    
    /**
     Loads the ads for table placer
     */
    fileprivate func loadAds() {
        tablePlacer.loadAds(forAdUnitID: adUnit.id, targeting: dataSource.targetting)
    }
}

extension NativeAdTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCellFromNib(cellType: StatusTableViewCell.self)
        
        // Update the cell
        let fontName: String = dataSource.data[indexPath.row]
        cell.update(status: fontName, error: nil, isHighlighted: true)
        cell.nameLabel.font = UIFont(name: fontName, size: cell.nameLabel.font.pointSize)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
