//
//  BannerAdDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class BannerAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    /**
     Banner ad view.
     */
    private var adView: MPAdView!
    
    // MARK: - Status Properties
    
    /**
     Table of which events were triggered.
     */
    var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     The maximum desired ad size to request on a load
     */
    private var maxDesiredAdSize: CGSize = kMPPresetMaxAdSizeMatchFrame
    
    /**
     Status event titles that correspond to the events found in `MPAdViewDelegate`
     */
    lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad] = "adViewDidLoadAd(_:, adSize _:)"
        titleStrings[.didFailToLoad] = "adView(_:, didFailToLoadAdWithError _:)"
        titleStrings[.willPresentModal] = "willPresentModalViewForAd(_:)"
        titleStrings[.didDismissModal] = "didDismissModalViewForAd(_:)"
        titleStrings[.clicked] = "willLeaveApplicationFromAd(_:)"
        titleStrings[.didTrackImpression] = "mopubAd(_:, didTrackImpressionWith _:)"
        
        return titleStrings
    }()
    
    /**
     Optional status messages that correspond to the events found in the ad's delegate protocol.
     These are reset as part of `clearStatus`.
     */
    var messages: [AdEvent: String] = [:]
    
    // MARK: - Initialization
    
    /**
     Initializes the Banner ad data source.
     - Parameter adUnit: Banner ad unit.
     - Parameter size: Maximum desired ad size.
     */
    init(adUnit: AdUnit, bannerSize size: CGSize) {
        super.init()
        self.adUnit = adUnit
        
        // Instantiate the banner.
        adView = {
            let view: MPAdView = MPAdView(adUnitId: adUnit.id)
            view.delegate = self
            view.backgroundColor = .lightGray
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        maxDesiredAdSize = size
    }
    
    // MARK: - AdDataSource
    
    /**
     The actions available for the ad.
     */
    lazy var actions: [AdAction] = {
        return [.load]
    }()
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .willPresentModal, .didDismissModal, .clicked, .didTrackImpression]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return adView
    }
    
    /**
     Queries if the data source has an ad loaded.
     */
    private(set) var isAdLoaded: Bool = false
    
    /**
     Queries if the data source currently requesting an ad.
     */
    private(set) var isAdLoading: Bool = false
    
    // MARK: - Ad Loading
    
    private func loadAd() {
        guard !isAdLoading else {
            return
        }
        
        isAdLoading = true
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Populate the keywords and user data keywords before attempting
        // to load.
        adView.keywords = adUnit.keywords
        adView.userDataKeywords = adUnit.userDataKeywords
        adView.loadAd(withMaxAdSize: maxDesiredAdSize)
    }
}

extension BannerAdDataSource: MPAdViewDelegate {
    // MARK: - MPAdViewDelegate
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return delegate?.adPresentationViewController
    }
    
    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        isAdLoading = false
        isAdLoaded = true
        
        // Resize the MPAdView frame to match the creative height
        view.frame.size.height = adSize.height
        delegate?.adPresentationViewController?.view.setNeedsLayout()
                
        setStatus(for: .didLoad, message: "The ad size is \(adSize)") { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        isAdLoading = false
        isAdLoaded = false
        setStatus(for: .didFailToLoad, message: "\(error!.localizedDescription)") { [weak self] in
           self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func willPresentModalView(forAd view: MPAdView!) {
        setStatus(for: .willPresentModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        setStatus(for: .didDismissModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func mopubAd(_ ad: MPMoPubAd, didTrackImpressionWith impressionData: MPImpressionData?) {
        let message = impressionData?.description ?? "No impression data"
        setStatus(for: .didTrackImpression, message: message) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
}
