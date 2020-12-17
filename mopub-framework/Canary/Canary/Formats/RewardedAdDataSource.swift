//
//  RewardedAdDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class RewardedAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    // MARK: - Status Properties
    
    /**
     Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil
    
    /**
     Table of which events were triggered.
     */
    var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     Status event titles that correspond to the events found in `MPRewardedVideoDelegate`
     */
    lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]          = "rewardedVideoAdDidLoad(_:)"
        titleStrings[.didFailToLoad]    = "rewardedVideoAdDidFailToLoad(_:_:)"
        titleStrings[.didFailToPlay]    = "rewardedVideoAdDidFailToPlay(_:_:)"
        titleStrings[.willAppear]       = "rewardedVideoAdWillAppear(_:)"
        titleStrings[.didAppear]        = "rewardedVideoAdDidAppear(_:)"
        titleStrings[.willDisappear]    = "rewardedVideoAdWillDisappear(_:)"
        titleStrings[.didDisappear]     = "rewardedVideoAdDidDisappear(_:)"
        titleStrings[.didExpire]        = "rewardedVideoAdDidExpire(_:)"
        titleStrings[.clicked]          = "rewardedVideoAdDidReceiveTapEvent(_:)"
        titleStrings[.willLeaveApp]     = "rewardedVideoAdWillLeaveApplication(_:)"
        titleStrings[.shouldRewardUser] = "rewardedVideoAdShouldReward(_:_:)"
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
        
        // Register for rewarded video events
        MPRewardedVideo.setDelegate(self, forAdUnitId: adUnit.id)
    }
    
    deinit {
        MPRewardedVideo.removeDelegate(forAdUnitId: adUnit.id)
    }
    
    // MARK: - AdDataSource
    
    /**
     The ad unit information sections available for the ad.
     */
    lazy var information: [AdInformation] = {
        return [.id, .keywords, .userDataKeywords, .customData]
    }()
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        handlers[.show] = { [weak self] (sender) in
            self?.showAd(sender: sender)
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .didFailToPlay, .willAppear, .didAppear, .willDisappear, .didDisappear, .didExpire, .clicked, .willLeaveApp, .shouldRewardUser, .didTrackImpression]
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
        return MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnit.id)
    }
    
    /**
     Queries if the data source currently requesting an ad.
     */
    private(set) var isAdLoading: Bool = false
    
    // MARK: - Reward Selection
    
    /**
     Presents the reward selection as an action sheet. It will preselect the first item.
     - Parameter sender: `UIButton` element that initiated the reward selection
     - Parameter complete: Completion closure that's invoked when the select button has been pressed
     */
    private func presentRewardSelection(from sender: Any, complete: @escaping (() -> Swift.Void)) {
        // No rewards to present.
        guard let availableRewards = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id) as? [MPRewardedVideoReward],
            availableRewards.count > 0 else {
            return
        }
        
        // Create the alert.
        let alert = UIAlertController(title: "Choose Reward", message: nil, pickerViewDelegate: self, pickerViewDataSource: self, sender: sender)
        
        // Create the selection button.
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { _ in
            complete()
        }))
        
        // Present the alert
        delegate?.adPresentationViewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Ad Loading
    
    private func loadAd() {
        guard !isAdLoading else {
            return
        }
        
        isAdLoading = true
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Clear out previous reward.
        selectedReward = nil
        
        // Load the rewarded ad.
        MPRewardedVideo.loadAd(withAdUnitID: adUnit.id, keywords: adUnit.keywords, userDataKeywords: adUnit.userDataKeywords, location: nil, mediationSettings: nil)
    }
    
    private func showAd(sender: Any) {
        guard MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnit.id) else {
            print("Attempted to show a rewarded ad when it is not ready")
            return
        }
        
        // Prompt the user to select a reward
        presentRewardSelection(from: sender) { [weak self] in
            if let strongSelf = self {
                // Validate a reward was selected
                guard strongSelf.selectedReward != nil else {
                    print("No reward was selected")
                    return
                }
                
                // Present the ad.
                MPRewardedVideo.presentAd(forAdUnitID: strongSelf.adUnit.id, from: strongSelf.delegate?.adPresentationViewController, with: strongSelf.selectedReward, customData: strongSelf.adUnit.customData)
            }
        }
    }
}

extension RewardedAdDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - UIPickerViewDataSource
    
    // There will always be a single column of currencies
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id).count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let reward: MPRewardedVideoReward = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id)[row] as? MPRewardedVideoReward,
            let amount = reward.amount,
            let currency = reward.currencyType else {
            return nil
        }
        
        return "\(amount) \(currency)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let reward: MPRewardedVideoReward = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id)[row] as? MPRewardedVideoReward else {
            return
        }
        
        selectedReward = reward
    }
}

extension RewardedAdDataSource: MPRewardedVideoDelegate {
    // MARK: - MPRewardedVideoDelegate
    
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        isAdLoading = false
        setStatus(for: .didLoad) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        isAdLoading = false
        setStatus(for: .didFailToLoad, message: error.localizedDescription) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidFailToPlay(forAdUnitID adUnitID: String!, error: Error!) {
        setStatus(for: .didFailToPlay, message: error.localizedDescription) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdWillAppear(forAdUnitID adUnitID: String!) {
        setStatus(for: .willAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidAppear(forAdUnitID adUnitID: String!) {
        setStatus(for: .didAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdWillDisappear(forAdUnitID adUnitID: String!) {
        setStatus(for: .willDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        setStatus(for: .didDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidExpire(forAdUnitID adUnitID: String!) {
        setStatus(for: .didExpire) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdWillLeaveApplication(forAdUnitID adUnitID: String!) {
        setStatus(for: .willLeaveApp) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        let message = reward?.description ?? "No reward specified"
        setStatus(for: .shouldRewardUser, message: message) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func didTrackImpression(withAdUnitID adUnitID: String!, impressionData: MPImpressionData!) {
        let message = impressionData?.description ?? "No impression data"
        setStatus(for: .didTrackImpression, message: message) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
}
