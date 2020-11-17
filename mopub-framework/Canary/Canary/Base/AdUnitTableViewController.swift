//
//  AdUnitTableViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import AVFoundation

struct AdUnitTableViewControllerSegueIdentifier {
    static let ModallyPresentCameraInterfaceSegueIdentifier = "modallyPresentCameraInterfaceViewController"
    static let ModallyPresentManualEntryInterfaceSegueIdentifier = "modallyPresentManualEntryInterfaceViewController"
}

class AdUnitTableViewController: UIViewController {
    // Outlets from `Main.storyboard`
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem?
    
    // Table data source.
    fileprivate var dataSource: AdUnitDataSource? = nil
    
    // MARK: - Initialization
    
    /**
     Initializes the view controller's data source. This must be performed before
     `viewDidLoad()` is called.
     - Parameter dataSource: Data source for the view controller.
     */
    func initialize(with dataSource: AdUnitDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register reusable table cells and delegates
        AdUnitTableViewCell.register(with: tableView)
        AdUnitTableViewHeader.register(with: tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Ad Loading
    
    public func loadAd(with adUnit: AdUnit) {
        guard let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
            return
        }
        
        // Embed the destination ad view controller into a navigation controller so that
        // pushing onto the navigation stack will work.
        let navigationController: UINavigationController = UINavigationController(rootViewController: destination)
        splitViewController?.showDetailViewController(navigationController, sender: self)
    }
    
    /**
     Reloads the data source's data and refreshes the table view with the updated
     contents.
     */
    public func reloadData() {
        dataSource?.reloadData()
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    @IBAction func addButtonAction(_ sender: Any) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: QRCodeCameraInterfaceViewController.defaultMediaType)
        let showCameraButton = cameraAuthorizationStatus == .authorized || cameraAuthorizationStatus == .notDetermined ? true : false
        
        // If camera use is not authorized, show the manual interface without giving a choice
        if !showCameraButton {
            performSegue(withIdentifier: AdUnitTableViewControllerSegueIdentifier.ModallyPresentManualEntryInterfaceSegueIdentifier, sender: self)
            return
        }
        
        // If camera use is authorized, show action sheet with a choice between manual interface and camera interface
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Enter Ad Unit ID Manually", style: .default, handler: { [unowned self] _ in
            self.performSegue(withIdentifier: AdUnitTableViewControllerSegueIdentifier.ModallyPresentManualEntryInterfaceSegueIdentifier, sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Use QR Code", style: .default, handler: { [unowned self] _ in
            self.performSegue(withIdentifier: AdUnitTableViewControllerSegueIdentifier.ModallyPresentCameraInterfaceSegueIdentifier, sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            guard let barButtonItem = sender as? UIBarButtonItem else {
                assertionFailure("\(#function) sender is not `UIBarButtonItem` as expected")
                return
            }
            // ADF-4094: app will crash if popover source is not set for popover presentation
            popoverPresentationController.barButtonItem = barButtonItem
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension AdUnitTableViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.items(for: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let adUnit: AdUnit = dataSource?.item(at: indexPath) else {
            return UITableViewCell()
        }
        
        let adUnitCell = tableView.dequeueCellFromNib(cellType: AdUnitTableViewCell.self)
        adUnitCell.accessibilityIdentifier = adUnit.id
        adUnitCell.refresh(adUnit: adUnit)
        adUnitCell.setNeedsLayout()
        return adUnitCell
    }
}

extension AdUnitTableViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Intentionally not to deselect cell to help user to keep track of the long list
        guard let adUnit: AdUnit = dataSource?.item(at: indexPath) else {
            return
        }
        
        loadAd(with: adUnit)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header: AdUnitTableViewHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: AdUnitTableViewHeader.reuseId) as? AdUnitTableViewHeader,
            let title = dataSource?.sections[section] else {
            return nil
        }
        
        header.refresh(title: title)
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}
