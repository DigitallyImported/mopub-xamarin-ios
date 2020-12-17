//
//  TextAndToggleTableViewCell.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

final class TextAndToggleTableViewCell: UITableViewCell, TableViewCellRegisterable {
    
    /**
     The handler to call after the toggle is updated. The `Bool` argument represents if `isOn` state of the toggle.
     */
    typealias ToggleHandler = (Bool) -> Void

    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var toggle: UISwitch!
    private var toggleHandler: ToggleHandler?
    
    // MARK: - Functions
    
    @IBAction private func toggleValueDidChange(_ sender: UISwitch) {
        guard let toggleHandler = toggleHandler else {
            assertionFailure("\(#function) `toggleHandler` is nil")
            return
        }
        toggleHandler(sender.isOn)
    }
    
    /**
     Configure this cell after dequeuing.
     */
    func configure(title: String, toggleIsOn: Bool, toggleHandler: @escaping ToggleHandler) {
        titleLabel.text = title
        toggle.isOn = toggleIsOn
        self.toggleHandler = toggleHandler
    }
}
