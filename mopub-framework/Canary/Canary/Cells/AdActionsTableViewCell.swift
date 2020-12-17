//
//  AdActionsTableViewCell.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

final class AdActionsTableViewCell: UITableViewCell, TableViewCellRegisterable {
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var showAdButton: RoundedButton!
    @IBOutlet weak var loadAdButton: RoundedButton!
    
    // MARK: - Properties
    fileprivate var willLoadAd: AdActionHandler? = nil
    fileprivate var willShowAd: AdActionHandler? = nil
    
    // MARK: - IBActions
    @IBAction func onLoad(_ sender: Any) {
        willLoadAd?(sender)
    }
    
    @IBAction func onShow(_ sender: Any) {
        willShowAd?(sender)
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Accessibility
        loadAdButton.accessibilityIdentifier = AccessibilityIdentifier.adActionsLoad
        showAdButton.accessibilityIdentifier = AccessibilityIdentifier.adActionsShow
    }
    
    // MARK: - Refreshing
    func refresh(isAdLoading: Bool = false, loadAdHandler: AdActionHandler? = nil, showAdHandler: AdActionHandler? = nil, showButtonEnabled: Bool = false) {
        willLoadAd = loadAdHandler
        willShowAd = showAdHandler
        
        // Loading button state is only disabled if
        // 1. the show button is enabled and has a valid handler
        // OR
        // 2. the ad is currently loading.
        loadAdButton.isEnabled = (showAdHandler == nil || !showButtonEnabled) && !isAdLoading
        
        // Showing an ad is optional. Hide it if there is no show handler.
        showAdButton.isHidden = (showAdHandler == nil)
        showAdButton.isEnabled = showButtonEnabled
    }
}
