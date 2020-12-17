//
//  ManualEntryInterfaceViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class ManualEntryInterfaceViewController: UIViewController {
    /**
     The shared app delegate. This is used to access deep linking functionality contained in app delegate.
     */
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var selectedFormat: AdFormat = AdFormat.allCases[0] {
        didSet {
            adFormatButton?.setTitle(selectedFormat.rawValue, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button text to default ad format text
        adFormatButton.setTitle(selectedFormat.rawValue, for: .normal)
    }
    
    fileprivate func dismissAndShowAd(shouldSave: Bool) {
        guard let appDelegate = appDelegate else {
            return
        }
        
        // Attempt to create ad unit object
        let adUnit: AdUnit
        
        // Try creating the ad unit object from deep link URL first
        if let deepLinkURLText = deepLinkURLTextField.text,
            let deepLinkURL = URL(string: deepLinkURLText),
            let anAdUnit = AdUnit(url: deepLinkURL) {
            adUnit = anAdUnit
        }
        // If that doesn't work, try creating the ad unit object from manual fields
        else if let adUnitId = adUnitIdTextField.text,
            let anAdUnit = AdUnit(adUnitId: adUnitId, format: selectedFormat, name: nameTextField.text) {
            adUnit = anAdUnit
        }
        // If that doesn't work, show an alert to the user and return
        else {
            let alert = UIAlertController(title: nil, message: "Ad Unit ID or deep link URL is malformed or blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        // If everything is formed correctly, dismiss and show ad.
        navigationController?.dismiss(animated: true, completion: {
            _ = appDelegate.openMoPubAdUnit(adUnit: adUnit,
                                            onto: appDelegate.savedAdSplitViewController,
                                            shouldSave: shouldSave)
        })
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var adFormatButton: UIButton!
    @IBOutlet weak var adUnitIdTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var deepLinkURLTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func adFormatButtonAction(_ sender: Any) {
        // Create the alert.
        let alert = UIAlertController(title: "Choose Ad Type", message: nil, pickerViewDelegate: self, pickerViewDataSource: self, sender: sender)
        
        // Create the selection button.
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showAction(_ sender: Any) {
        dismissAndShowAd(shouldSave: false)
    }
    
    @IBAction func showAndSaveAction(_ sender: Any) {
        dismissAndShowAd(shouldSave: true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ManualEntryInterfaceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - UIPickerViewDataSource
    
    // There will always be a single column ad formats
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AdFormat.allCases.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AdFormat.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFormat = AdFormat.allCases[row]
    }
}

extension ManualEntryInterfaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
