//
//  AppDelegate+Initialization.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

fileprivate let kAdUnitId = "0ac59b0996d947309c33f59d6676399f"

extension AppDelegate {
    /**
     Check if the Canary app has a cached ad unit ID for consent. If not, the app will present an alert dialog allowing
     custom ad unit ID entry.
     */
    func checkAndInitializeSdk() {
        // Already have a valid cached ad unit ID for consent. Just initialize the SDK.
        if UserDefaults.standard.cachedAdUnitId.count > 0 {
            initializeMoPubSdk(adUnitIdForConsent: UserDefaults.standard.cachedAdUnitId)
            return
        }
        
        // Need to prompt for an ad unit.
        let prompt: UIAlertController = UIAlertController(title: "MoPub SDK initialization", message: "Enter an ad unit ID to use for consent:", preferredStyle: .alert)
        var adUnitIdTextField: UITextField? = nil
        prompt.addTextField { textField in
            textField.placeholder = "Ad Unit ID"
            adUnitIdTextField = textField       // Capture the text field so we can later read the value
        }
        prompt.addAction(UIAlertAction(title: "Use default ID", style: .destructive, handler: { _ in
            UserDefaults.standard.cachedAdUnitId = kAdUnitId;
            self.initializeMoPubSdk(adUnitIdForConsent: kAdUnitId)
        }))
        prompt.addAction(UIAlertAction(title: "Use inputted ID", style: .default, handler: { _ in
            let adUnitID = adUnitIdTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "";
            UserDefaults.standard.cachedAdUnitId = adUnitID;
            self.initializeMoPubSdk(adUnitIdForConsent: adUnitID);
        }))
        
        DispatchQueue.main.async {
            self.containerViewController.present(prompt, animated: true, completion: nil)
        }
    }
    
    /**
     Initializes the MoPub SDK with the given ad unit ID used for consent management.
     - Parameter adUnitIdForConsent: This value must be a valid ad unit ID associated with your app.
     */
    func initializeMoPubSdk(adUnitIdForConsent: String) {
        // MoPub SDK initialization
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitIdForConsent)
        sdkConfig.globalMediationSettings = []
        sdkConfig.loggingLevel = .info
        
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            // Update the state of the menu now that the SDK has completed initialization.
            if let menuController = self.containerViewController.menuViewController {
                menuController.updateIfNeeded()
            }
            
            // Request user consent to collect personally identifiable information
            // used for targeted ads
            if let tabBarController = self.containerViewController.mainTabBarController {
                self.displayConsentDialog(from: tabBarController)
            }
        }
    }
    
}
