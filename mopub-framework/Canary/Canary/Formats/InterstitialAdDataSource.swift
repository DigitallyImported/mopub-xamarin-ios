//
//  InterstitialAdDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class InterstitialAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    /**
     Interstitial ad
     */
    private var interstitialAd: MPInterstitialAdController!
    
    // MARK: - Status Properties
    
    /**
     Table of which events were triggered.
     */
    var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     Status event titles that correspond to the events found in `MPInterstitialAdControllerDelegate`
     */
    lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]            = "interstitialDidLoadAd(_:)"
        titleStrings[.didFailToLoad]      = "interstitialDidFailToLoadAd(_:)"
        titleStrings[.willAppear]         = "interstitialWillAppear(_:)"
        titleStrings[.didAppear]          = "interstitialDidAppear(_:)"
        titleStrings[.willDisappear]      = "interstitialWillDisappear(_:)"
        titleStrings[.didDisappear]       = "interstitialDidDisappear(_:)"
        titleStrings[.didExpire]          = "interstitialDidExpire(_:)"
        titleStrings[.clicked]            = "interstitialDidReceiveTapEvent(_:)"
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
     Initializes the Interstitial ad data source.
     - Parameter adUnit: Interstitial ad unit.
     */
    init(adUnit: AdUnit) {
        super.init()
        self.adUnit = adUnit
        
        // Instantiate the interstitial ad.
        interstitialAd = MPInterstitialAdController(forAdUnitId: adUnit.id)
        interstitialAd.delegate = self
    }
    
    // MARK: - AdDataSource
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        handlers[.show] = { [weak self] _ in
            self?.showAd()
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .willAppear, .didAppear, .willDisappear, .didDisappear, .didExpire, .clicked, .didTrackImpression]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return nil
    }
    
    /**
     Queries if the data source has an ad loaded.
     */
    var isAdLoaded: Bool {
        return interstitialAd.ready
    }
    
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
        interstitialAd.keywords = adUnit.keywords
        interstitialAd.userDataKeywords = adUnit.userDataKeywords
        interstitialAd.loadAd()
    }
    
    private func showAd() {
        guard interstitialAd.ready else {
            print("Attempted to show an interstitial ad when it is not ready")
            return
        }
        
        interstitialAd.show(from: delegate?.adPresentationViewController)
    }
}

extension InterstitialAdDataSource: MPInterstitialAdControllerDelegate {
    // MARK: - MPInterstitialAdControllerDelegate
    
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        isAdLoading = false
        setStatus(for: .didLoad) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        isAdLoading = false
        // The interstitial load failure doesn't give back an error reason; assume clear response
        setStatus(for: .didFailToLoad, message: "No ad available") { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .willAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialWillDisappear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .willDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidDisappear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didExpire) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
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
