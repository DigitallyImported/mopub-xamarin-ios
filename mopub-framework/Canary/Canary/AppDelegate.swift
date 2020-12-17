//
//  AppDelegate.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

let kAppId = "112358"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    /**
     Main application window.
     */
    var window: UIWindow?
    
    /**
     Main application's container controller.
     */
    var containerViewController: ContainerViewController!
    
    /**
     Saved ads split view controller.
     */
    var savedAdSplitViewController: UISplitViewController?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.shouldClearCachedNetworks {
            MoPub.sharedInstance().clearCachedNetworks() // do this before initializing the MoPub SDK
            print("\(#function) cached networks are cleared")
        }
        
        // Extract the UI elements for easier manipulation later.
        // Calls to `loadViewIfNeeded()` are needed to load any children view controllers
        // before `viewDidLoad()` occurs.
        containerViewController = (window?.rootViewController as! ContainerViewController)
        containerViewController.loadViewIfNeeded()
        savedAdSplitViewController = containerViewController.mainTabBarController?.viewControllers?[1] as? UISplitViewController
        
        // Additional configuration for internal target.
        #if INTERNAL
        Internal.sharedInstance.initialize(with: containerViewController)
        #endif

        // MoPub SDK initialization
        checkAndInitializeSdk()

        // Conversion tracking
        MPAdConversionTracker.shared().reportApplicationOpen(forApplicationID: kAppId)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "mopub" && url.host == "load" {
            return openMoPubUrl(url: url, onto: savedAdSplitViewController, shouldSave: true)
        }
        return true
    }
    
    // MARK: - Deep Links

    /**
     Attempts to open a valid `mopub://` scheme deep link URL
     - Parameter url: MoPub deep link URL
     - Parameter splitViewController: Split view controller that will present the opened deep link
     - Parameter shouldSave: Flag indicating that the ad unit that was opened should be saved
     - Returns: true if successfully shown, false if not
     */
    func openMoPubUrl(url: URL, onto splitViewController: UISplitViewController?, shouldSave: Bool) -> Bool {
        // Get adUnit object from the URL. If an adUnit is not obtainable from the URL, return false.
        guard let adUnit = AdUnit(url: url) else {
            return false
        }
        
        return openMoPubAdUnit(adUnit: adUnit, onto: splitViewController, shouldSave: shouldSave)
    }
    
    
    /**
     Attempts to open a valid `AdUnit` object instance
     - Parameter adUnit: MoPub `AdUnit` object instance
     - Parameter splitViewController: Split view controller that will present the opened deep link
     - Parameter shouldSave: Flag indicating that the ad unit that was opened should be saved
     - Returns: true if successfully shown, false if not
     */
    func openMoPubAdUnit(adUnit: AdUnit, onto splitViewController: UISplitViewController?, shouldSave: Bool) -> Bool {
        // Generate the destinate view controller and attempt to push the destination to the
        // Saved Ads navigation controller.
        guard let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
                return false
        }
        
        DispatchQueue.main.async {
            // If the ad unit should be saved, we will switch the tab to the saved ads
            // tab and then push the view controller on that navigation stack.
            self.containerViewController.mainTabBarController?.selectedIndex = 1
            if shouldSave {
                SavedAdsManager.sharedInstance.addSavedAd(adUnit: adUnit)
            }
            
            splitViewController?.showDetailViewController(destination, sender: splitViewController)
        }
        return true
    }
}
