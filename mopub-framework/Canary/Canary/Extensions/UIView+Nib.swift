//
//  UIView+Nib.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

extension UIView {
    func loadViewFromNib(nibName: String?) -> UIView? {
        guard let nibName = nibName else {
            return nil
        }
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func sizeFitting(view: UIView) -> CGSize {
        var fittingSize: CGSize = .zero
        if #available(iOS 11, *) {
            fittingSize = CGSize(width: view.bounds.width - (view.safeAreaInsets.left + view.safeAreaInsets.right), height: 0)
        }
        else {
            fittingSize = CGSize(width: view.bounds.width, height: 0)
        }
        
        let size = systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return size
    }
}
