//
//  UITableView+Utility.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

extension UITableView {
    /**
     Dequeue a nib cell from the table view, and register the cell if the first dequeue attempt fails.
     Note: This function only works if the nib file has the same name as the cell.
     - Parameter cellType: The type of expected cell.
     - Returns: A reusable instance of `cellType`.
     */
    func dequeueCellFromNib<T: TableViewCellRegisterable>(cellType: T.Type) -> T {
        let cellName = T.className
        
        if let cell = dequeueReusableCell(withIdentifier: cellName) as? T {
            return cell
        } else {
            register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
            guard let cell = dequeueReusableCell(withIdentifier: cellName) as? T else {
                fatalError("\(#function) failed to dequeue cell \(cellName) after cell registration")
            }
            return cell
        }
    }
}
