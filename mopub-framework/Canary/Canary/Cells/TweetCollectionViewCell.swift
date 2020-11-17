//
//  TweetCollectionViewCell.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class TweetCollectionViewCell: UICollectionViewCell {
    // IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    // Constraints
    private var widthConstraint: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        // Initially set the width constraint to be 300px.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 300)
    }
    
    // MARK: - Cell Registration
    
    /**
     Constant representing a default reuseable collection cell ID.
     */
    static let reuseId: String = "TweetCollectionViewCell"
    
    /**
     Registers this table cell with a given table using the `reuseId` constant.
     - Parameter collectionView: A valid collection view to register this cell.
     */
    class func registerCell(collectionView: UICollectionView) -> Void {
        let nib = UINib(nibName: reuseId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseId)
    }
    
    // MARK: - Cell Refreshing
    
    /**
     Updates the contents of the cell with the new tweet.
     - Parameter userIcon: The user's icon
     - Parameter userName: The user's name
     - Parameter tweet: Contents of the tweet
     */
    func refresh(userIcon: UIImage, userName: String, tweet: String) -> Void {
        iconImageView.image = userIcon
        titleLabel.text = userName
        contentLabel.text = tweet
    }
    
    // MARK: - Cell Sizing
    
    var cellWidth: CGFloat {
        get {
            return contentView.bounds.size.width
        }
        set {
            widthConstraint.constant = newValue
            widthConstraint.isActive = true
            updateConstraintsIfNeeded()
        }
    }
    
    /**
     Calculates the estimated size of the cell.
     */
    var cellSize: CGSize {
        let contentSize: CGSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let margin: CGFloat = iconImageView.frame.origin.y
        let height: CGFloat = max(contentSize.height, iconImageView.bounds.size.height).rounded(.up) + 2 * margin
        
        return CGSize(width: widthConstraint.constant, height: height)
    }
}
