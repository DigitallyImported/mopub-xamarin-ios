//
//  NativeAdCollectionViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import LoremIpsum
import MoPub

@objc(NativeAdCollectionViewController)
class NativeAdCollectionViewController: UIViewController, AdViewController {
    // MARK: - Constants
    struct Constants {
        static let iconSize: CGSize = CGSize(width: 50.0, height: 50.0)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    // Size calculations
    private var sizingCell: TweetCollectionViewCell!
    
    // MARK: - Data Sources
    
    /**
     Data Source
     */
    fileprivate var dataSource: NativeAdCollectionDataSource!
    
    /**
     Colleciton placer
     */
    private var collectionPlacer: MPCollectionViewAdPlacer!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---------------------------------------------------------------
        // It is assumed that at this point, `dataSource` is initialized
        // and ready to be used.
        // ---------------------------------------------------------------
        
        // Load a collection cell for the explicit purposes of size calculations.
        sizingCell = {
            let nib = Bundle.main.loadNibNamed("TweetCollectionViewCell", owner: self, options: nil)
            return (nib?.first as! TweetCollectionViewCell)
        }()
        
        // Construct the collection placer
        collectionPlacer = MPCollectionViewAdPlacer(collectionView: collectionView, viewController: self, rendererConfigurations: dataSource.rendererConfigurations)
        
        // Register the collection cells
        TweetCollectionViewCell.registerCell(collectionView: collectionView)
        
        // Assign the delegates
        collectionView.mp_setDataSource(self)
        collectionView.mp_setDelegate(self)
        
        // Load the ads
        loadAds()
        
        // Set the title
        title = adUnit.name
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Rotation will occur, invalidate the current collection layout and rerender
        // the collection
        collectionViewLayout.invalidateLayout()
        collectionView.mp_reloadData()
    }
    
    // MARK: - DisplayableAd
    
    /**
     Ad unit
     */
    var adUnit: AdUnit {
        get {
            return dataSource.adUnit
        }
        set {
            dataSource = NativeAdCollectionDataSource(adUnit: newValue)
        }
    }
    
    /**
     Instantiates this instance using the a nib file.
     - Parameter adUnit: Ad unit to use with the `AdViewController`.
     */
    static func instantiateFromNib(adUnit: AdUnit) -> Self {
        // The reason for the generic method in this static, is to preserve
        // the original type of the caller when instantiating an instance.
        // For example: If class A is a subclass of AdTableViewController,
        // this will return an initialized instance of type A.
        // Without the generics, this will return type AdTableViewController.
        func instantiateFromNib<T: UIViewController>(_ viewType: T.Type) -> T {
            return T.init(nibName: "NativeAdCollectionViewController", bundle: nil)
        }
        
        let instance = instantiateFromNib(self)
        instance.adUnit = adUnit
        
        return instance
    }
    
    // MARK: - Ad Loading
    
    /**
     Loads the ads for table placer
     */
    fileprivate func loadAds() {
        collectionPlacer.loadAds(forAdUnitID: adUnit.id, targeting: dataSource.targeting)
    }
}

extension NativeAdCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Cell Updating
    
    func update(cell: TweetCollectionViewCell, at indexPath: IndexPath) -> TweetCollectionViewCell {
        let data = dataSource.data[indexPath.row]
        let icon: UIImage = data.color.image(size: Constants.iconSize)
        
        // Only for Regular:Regular size class will we attempt to display
        // the cells at half width (2 column) format.
        let numberColumns: Int = collectionView.traitCollection.verticalSizeClass == .regular && collectionView.traitCollection.horizontalSizeClass == .regular ? 2 : 1
        let marginsAndInsets = collectionViewLayout.sectionInset.left + collectionViewLayout.sectionInset.right + collectionViewLayout.minimumInteritemSpacing * (CGFloat(numberColumns - 1))
        let width = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(numberColumns)).rounded(.down)
        cell.cellWidth = width
        
        // Update the contents of the cell
        cell.refresh(userIcon: icon, userName: data.name, tweet: data.tweet)
        cell.layoutIfNeeded()
        
        return cell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Guard against being unable to retrieve the cell from the collection view.
        guard let cell: TweetCollectionViewCell = collectionView.mp_dequeueReusableCell(withReuseIdentifier: TweetCollectionViewCell.reuseId, for: indexPath) as? TweetCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return update(cell: cell, at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Update the sizing cell with the current information and determine the minimum amount of
        // screen realestate needed to properly display the cell.
        let updatedSizingCell = update(cell: sizingCell, at: indexPath)
        var size = updatedSizingCell.cellSize
        
        // Round up any fractional sizes to improve rendering performance.
        size.width.round(.down)
        size.height.round(.up)
        
        return size
    }
}
