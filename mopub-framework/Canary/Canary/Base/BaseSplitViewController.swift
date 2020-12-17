//
//  BaseSplitViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class BaseSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let idiom = UIScreen.main.traitCollection.userInterfaceIdiom
        preferredDisplayMode = (idiom == .pad ? .allVisible : .automatic)
    }
}
