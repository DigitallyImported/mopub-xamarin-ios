//
//  UIAlertController+Picker.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

extension UIAlertController {
    // Creates a `UIAlertController` in the action sheet style with a `UIPickerView` attached
    public convenience init(title: String?, message: String?, pickerViewDelegate: UIPickerViewDelegate?, pickerViewDataSource: UIPickerViewDataSource?, sender: Any?) {
        self.init(title: title, message: message, preferredStyle: .actionSheet)
        
        isModalInPopover = true
        
        // Make picker view
        let pickerView: UIPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        pickerView.dataSource = pickerViewDataSource
        pickerView.delegate = pickerViewDelegate
        
        // Configure popover appearance.
        if let popoverController = popoverPresentationController,
            let showButton: UIButton = sender as? UIButton {
            popoverController.sourceView = showButton
            popoverController.sourceRect = showButton.bounds
            popoverController.permittedArrowDirections = [.up, .down]
        }
        
        // We need to add the pickerView to contentViewController of the
        // UIAlertController so that it occupies the content section instead of
        // being a subview (which will obscure the action buttons).
        let container = UIViewController()
        container.preferredContentSize = pickerView.bounds.size
        container.view.addSubview(pickerView)
        setValue(container, forKey: "contentViewController")
        
        // We need to constrain the edges of the pickerView to the UIAlertController
        // view so that the pickerView is aligned properly.
        let constraints: [NSLayoutConstraint] = [
            pickerView.leftAnchor.constraint(equalTo: container.view.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: container.view.rightAnchor),
            pickerView.topAnchor.constraint(equalTo: container.view.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
            ]
        NSLayoutConstraint.activate(constraints)
        
        // Select the first row by default.
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerViewDelegate?.pickerView?(pickerView, didSelectRow: 0, inComponent: 0)
    }
}
