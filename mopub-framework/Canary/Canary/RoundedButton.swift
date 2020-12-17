//
//  RoundedButton.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    // MARK: - View Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            
            return UIColor(cgColor: cgColor)
            
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }
    
    // MARK: - Overrides
    
    /**
     Previous border color set when the button is disabled
     */
    private var originalBorderColor: UIColor? = nil
    
    /**
     Previous background color set when the button is disabled
     */
    private var originalBackgroundColor: UIColor? = nil
    
    override var isEnabled: Bool {
        didSet {
            // Transition from enabled to disabled
            if oldValue && !isEnabled {
                // Border color exists, save it's current color and apply the
                // disabled color scheme
                if let border = borderColor {
                    originalBorderColor = border
                    borderColor = titleColor(for: .disabled)
                }
                
                // Background color exists, save it's current color and apply
                // the disabled color scheme
                if let bgColor = backgroundColor {
                    originalBackgroundColor = bgColor
                    backgroundColor = UIColor.lightGray
                }
            }
            // Transition from disabled to enabled
            else if !oldValue && isEnabled {
                // Border color previously existed, reapply it
                if let border = originalBorderColor {
                    borderColor = border
                    originalBorderColor = nil
                }
                
                // Background color previously existed, reapply it
                if let bgColor = originalBackgroundColor {
                    backgroundColor = bgColor
                    originalBackgroundColor = nil
                }
            }
        }
    }
}
