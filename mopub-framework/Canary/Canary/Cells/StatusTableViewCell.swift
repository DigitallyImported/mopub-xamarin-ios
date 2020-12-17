//
//  StatusTableViewCell.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

final class StatusTableViewCell: UITableViewCell, TableViewCellRegisterable {
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Update
    
    /**
     Updates the state of the cell.
     - Parameter status: Status title
     - Parameter error: Optional error message to display under the status. By default this is `nil`.
     - Parameter isHightlighted: Optional flag indicating that the status text should be highlighted.
     By default this value is `false`.
     */
    func update(status: String, error: String? = nil, isHighlighted: Bool = false) {
        // Update label text
        nameLabel.text = status
        messageLabel.text = error
        
        // Update text highlighted state
        nameLabel.textColor = isHighlighted ? .black : .lightGray
        accessoryType = isHighlighted ? .checkmark : .none

        // Update the visible state of the message label
        messageLabel.isHidden = (error == nil)
        
        setNeedsLayout()
    }
}
