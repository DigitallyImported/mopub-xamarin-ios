//
//  NativeAdView.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

/**
 Provides a common native ad view.
 */
@IBDesignable
class NativeAdView: UIView {
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var privacyInformationIconImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    // IBInspectable
    @IBInspectable var nibName: String? = "NativeAdView"
    
    // Content View
    private(set) var contentView: UIView? = nil
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNib()
    }
    
    func setupNib() -> Void {
        guard let view = loadViewFromNib(nibName: nibName) else {
            return
        }
        
        // Accessibility
        mainImageView.accessibilityIdentifier = AccessibilityIdentifier.nativeAdImageView
        
        // Size the nib's view to the container and add it as a subview.
        view.frame = bounds
        addSubview(view)
        contentView = view
        
        // Pin the anchors of the content view to the view.
        let viewConstraints = [view.topAnchor.constraint(equalTo: topAnchor),
                               view.bottomAnchor.constraint(equalTo: bottomAnchor),
                               view.leadingAnchor.constraint(equalTo: leadingAnchor),
                               view.trailingAnchor.constraint(equalTo: trailingAnchor)]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupNib()
        contentView?.prepareForInterfaceBuilder()
    }
}

extension NativeAdView: MPNativeAdRendering {
    // MARK: - MPNativeAdRendering
    
    func nativeTitleTextLabel() -> UILabel! {
        return titleLabel
    }
    
    func nativeMainTextLabel() -> UILabel! {
        return mainTextLabel
    }
    
    func nativeCallToActionTextLabel() -> UILabel! {
        return callToActionLabel
    }
    
    func nativeIconImageView() -> UIImageView! {
        return iconImageView
    }
    
    func nativeMainImageView() -> UIImageView! {
        return mainImageView
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView! {
        return privacyInformationIconImageView
    }
    
    func nativeVideoView() -> UIView! {
        return videoView
    }
}
