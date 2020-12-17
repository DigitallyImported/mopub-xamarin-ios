//
//  PreferredWidthLabel.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class PreferredWidthLabel: UILabel {
    override var bounds: CGRect {
        didSet {
            if bounds.size.width != oldValue.size.width {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    override func updateConstraints() {
        if preferredMaxLayoutWidth != bounds.size.width {
            preferredMaxLayoutWidth = bounds.size.width
        }
        
        super.updateConstraints()
    }
}
