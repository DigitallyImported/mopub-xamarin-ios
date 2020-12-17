//
//  CollapsibleAdapterInfoTableViewCell.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

final class CollapsibleAdapterInfoTableViewCell: UITableViewCell, TableViewCellRegisterable {
    // MARK: - Constants
    struct Constants {
        // The padding and spacing constant for the stack view elements
        static let padding: CGFloat = 4
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var adapterVersionLabel: UILabel!
    @IBOutlet weak var networkSdkVersionLabel: UILabel!
    @IBOutlet weak var hasBiddingTokenLabel: UILabel!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    var stackViewHeightConstraint: NSLayoutConstraint? = nil
    
    override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()
        
        // Information stack view should be collapsed
        if let stackViewHeightConstraint = stackViewHeightConstraint {
            stackViewHeightConstraint.isActive = true
            stackViewTopConstraint.constant = 0
        }
        // Information stack view should be expanded
        else {
            stackViewTopConstraint.constant = Constants.padding
        }
    }
    
    // MARK: - Properties
    
    /**
     Queries the collapsed state of the cell
     */
    var isCollapsed: Bool {
        get {
            return (stackViewHeightConstraint != nil)
        }
        set {
            // Collapse the information stack view
            if newValue && stackViewHeightConstraint == nil {
                accessoryType = .disclosureIndicator
                stackView.spacing = 0
                stackViewHeightConstraint = stackView.heightAnchor.constraint(equalToConstant: 0)
                setNeedsUpdateConstraints()
            }
            // Expand the information stack view
            else if !newValue && stackViewHeightConstraint != nil {
                accessoryType = .none
                stackView.spacing = Constants.padding
                stackViewHeightConstraint?.isActive = false
                stackViewHeightConstraint = nil
                setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: - Cell Updating
    
    func update(adapterName: String, info: MPAdapterConfiguration, isCollapsed collapsed: Bool = true) {
        titleLabel.text = adapterName.replacingOccurrences(of: "AdapterConfiguration", with: "")
        adapterVersionLabel.text = info.adapterVersion
        networkSdkVersionLabel.text = info.networkSdkVersion
        hasBiddingTokenLabel.text = info.biddingToken != nil ? "true" : "false"
        isCollapsed = collapsed
        setNeedsLayout()
    }
    
    func update(title: String) {
        titleLabel.text = title
        adapterVersionLabel.text = nil
        networkSdkVersionLabel.text = nil
        hasBiddingTokenLabel.text = nil
        isCollapsed = true
        setNeedsLayout()
    }
}
