//
//  ContainerViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class ContainerViewController: UIViewController {
    // Constants
    struct Constants {
        static let menuAnimationDuration: TimeInterval = 0.25 //seconds
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var menuContainerLeadingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuContainerWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Menu Gesture Recognizers
    
    private var menuCloseGestureRecognizer: UISwipeGestureRecognizer!
    private var menuCloseTapGestureRecognizer: UITapGestureRecognizer!
    private var menuOpenGestureRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - Properties
    
    /**
     Current collection of override traits for mainTabBarController.
     */
    var forcedTraitCollection: UITraitCollection?  = nil {
        didSet {
            updateForcedTraitCollection()
        }
    }
    
    /**
     Main TabBar Controller of the app.
     */
    private(set) var mainTabBarController: MainTabBarController? = nil
    
    /**
     Menu TableView Controller of the app.
     */
    private(set) var menuViewController: MenuViewController? = nil
    
    // MARK: - Forced Traits
    
    func setForcedTraits(for size: CGSize) {
        let device = traitCollection.userInterfaceIdiom
        let isPortrait: Bool = view.bounds.size.width < view.bounds.size.height
        
        switch (device, isPortrait) {
        case (.pad, true): forcedTraitCollection = UITraitCollection(horizontalSizeClass: .compact)
        default: forcedTraitCollection = nil
        }
    }
    
    /**
     Updates the Main Tab Bar controller with the new trait overrides.
     */
    func updateForcedTraitCollection() {
        if let vc = mainTabBarController {
            setOverrideTraitCollection(forcedTraitCollection, forChild: vc)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the children view controllers are loaded, each will perform
        // a segue which we must capture to initialize the view controller
        // properties.
        switch segue.identifier {
        case "onEmbedTabBarController":
            mainTabBarController = segue.destination as? MainTabBarController
            break
        case "onEmbedMenuController":
            menuViewController = segue.destination as? MenuViewController
            break
        default:
            break
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup trait overrides
        setForcedTraits(for: view.bounds.size)
        
        // Initialize the gesture recognizers and attach them to the view.
        menuCloseGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMenuClose(_:)))
        menuCloseGestureRecognizer.direction = .left
        view.addGestureRecognizer(menuCloseGestureRecognizer)
        
        menuCloseTapGestureRecognizer = UITapGestureRecognizer (target: self, action: #selector(tapMenuClose(_:)))
        menuCloseTapGestureRecognizer.isEnabled = false
        menuCloseTapGestureRecognizer.delegate = self
        view.addGestureRecognizer(menuCloseTapGestureRecognizer)
        
        menuOpenGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeMenuOpen(_:)))
        menuOpenGestureRecognizer.direction = .right
        view.addGestureRecognizer(menuOpenGestureRecognizer)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.setForcedTraits(for: size)
        }, completion: nil)
    }

    // MARK: - Menu
    
    /**
     Closes the menu if it open.
     */
    func closeMenu() {
        swipeMenuClose(menuCloseGestureRecognizer)
    }
    
    @objc func swipeMenuClose(_ sender: UISwipeGestureRecognizer) {
        // Do nothing if the menu is not fully open since it may either
        // be closed, or in the process of being closed.
        guard menuContainerLeadingEdgeConstraint.constant == 0 else {
            return
        }
        
        // Disable the tap outside of menu to close gesture recognizer.
        menuCloseTapGestureRecognizer.isEnabled = false
        
        // Close the menu by setting the leading edge constraint to the negative width,
        // which will put it offscreen.
        UIView.animate(withDuration: Constants.menuAnimationDuration, animations: {
            self.menuContainerLeadingEdgeConstraint.constant = -self.menuContainerWidthConstraint.constant
            self.view.layoutIfNeeded()
        }) { _ in
            // Re-enable user interaction for the main content container.
            self.mainTabBarController?.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func swipeMenuOpen(_ sender: UISwipeGestureRecognizer) {
        // Do nothing if the menu is already open or in the process of opening.
        guard (menuContainerWidthConstraint.constant + menuContainerLeadingEdgeConstraint.constant) == 0 else {
            return
        }
        
        // Disable user interaction for the main content container.
        self.mainTabBarController?.view.isUserInteractionEnabled = false
        
        // Open the menu by setting the leading edge constraint back to zero.
        UIView.animate(withDuration: Constants.menuAnimationDuration, animations: {
            self.menuContainerLeadingEdgeConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            // Enable the tap outside of menu to close gesture recognizer.
            self.menuCloseTapGestureRecognizer.isEnabled = true
        }
    }
    
    @objc func tapMenuClose(_ sender: UITapGestureRecognizer) {
        // Allow any previously queued animations to finish before attempting to close the menu
        view.layoutIfNeeded()
        
        // Close the menu
        closeMenu()
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only handle the menu tap to close gesture
        guard gestureRecognizer == menuCloseTapGestureRecognizer else {
            return true
        }
        
        // If the menu is not fully open, disregard the tap.
        guard menuContainerLeadingEdgeConstraint.constant == 0 else {
            return false
        }
        
        // If the tap intersects the open menu, disregard the tap.
        guard gestureRecognizer.location(in: view).x > menuContainerWidthConstraint.constant else {
            return false
        }
        
        return true
    }
}
