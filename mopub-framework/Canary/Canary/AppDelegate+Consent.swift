//
//  AppDelegate+Consent.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

extension AppDelegate {
    /**
     Loads the consent request dialog (if not already loaded), and presents the dialog
     from the specified view controller. If user consent is not needed, nothing is done.
     - Parameter presentingViewController: `UIViewController` used for presenting the dialog
     */
    func displayConsentDialog(from presentingViewController: UIViewController) {
        // Verify that we need to acquire consent.
        guard MoPub.sharedInstance().shouldShowConsentDialog else {
            return
        }
        
        // Load the consent dialog if it's not available. If it is already available,
        // the completion block will immediately fire.
        MoPub.sharedInstance().loadConsentDialog(completion: { (error: Error?) in
            guard error == nil else {
                print("Consent dialog failed to load: \(String(describing: error?.localizedDescription))")
                return
            }
            
            MoPub.sharedInstance().showConsentDialog(from: presentingViewController, completion: nil)
        })
    }
}
