//
//  AdDataSource.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Possible information to display along with the ad
 */
enum AdInformation {
    case id
    case keywords
    case userDataKeywords
    case customData
}

/**
 Possible actions for an ad
 */
enum AdAction {
    case load
    case show
}

/**
 Possible ad events
 */
enum AdEvent {
    case didLoad
    case didFailToLoad
    case didFailToPlay
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case willPresentModal
    case didDismissModal
    case didExpire
    case clicked
    case willLeaveApp
    case shouldRewardUser
    case didTrackImpression
}

/**
 Type-alias for ad action closures.
 The format of the handler is: (sender of the action) -> Void
 */
typealias AdActionHandler = ((Any) -> Swift.Void)

/**
 Delegate for presenting the data source's ad.
 */
protocol AdDataSourcePresentationDelegate: class {
    /**
     View controller used to present models (either the ad itself or any click through destination).
     */
    var adPresentationViewController: UIViewController? { get }
    
    /**
     Table view used to present the contents of the data source.
     */
    var adPresentationTableView: UITableView { get }
}

/**
 Protocol to specifying an ad's rendering on screen.
 */
protocol AdDataSource: class {
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    var delegate: AdDataSourcePresentationDelegate? { get set }
    
    /**
     The ad unit information sections available for the ad.
     */
    var information: [AdInformation] { get }
    
    /**
     The actions available for the ad.
     */
    var actions: [AdAction] { get }
    
    /**
     Closures associated with each available ad action.
     */
    var actionHandlers: [AdAction: AdActionHandler] { get }
    
    /**
     The status events available for the ad.
     */
    var events: [AdEvent] { get }
    
    /**
     Table of which events were triggered.
     */
    var eventTriggered: [AdEvent: Bool] { get set }
    
    /**
     Ad unit associated with the ad.
     */
    var adUnit: AdUnit! { get }
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? { get }
    
    /**
     Queries if the data source has an ad loaded.
     */
    var isAdLoaded: Bool { get }
    
    /**
     Queries if the data source currently requesting an ad.
     */
    var isAdLoading: Bool { get }
    
    /**
     Status event titles that correspond to the events found in the ad's delegate protocol.
     */
    var title: [AdEvent: String] { get }
    
    /**
     Optional status messages that correspond to the events found in the ad's delegate protocol.
     These are reset as part of `clearStatus`.
     */
    var messages: [AdEvent: String] { get set }
    
    /**
     Retrieves the display status for the event.
     - Parameter event: Status event.
     - Returns: A tuple containing the status display title, optional message, and highlighted state.
     */
    func status(for event: AdEvent) -> (title: String, message: String?, isHighlighted: Bool)
    
    /**
     Sets the status for the event to highlighted. If the status is already highlighted,
     nothing is done.
     - Parameter event: Status event.
     - Parameter message: optional string containing status message.
     - Parameter complete: Completion closure.
     */
    func setStatus(for event: AdEvent, message: String?, complete:(() -> Swift.Void))
    
    /**
     Clears the highlighted state for all status events.
     - Parameter complete: Completion closure.
     */
    func clearStatus(complete:(() -> Swift.Void))
}

extension AdDataSource {
    /**
     The status events available for the ad.
     */
    var events: [AdEvent] {
        get {
            return [.didTrackImpression]
        }
    }
    
    /**
     The ad unit information sections available for the ad.
     */
    var information: [AdInformation] {
        get {
            return [.id, .keywords, .userDataKeywords]
        }
    }
    
    /**
     The actions available for the ad.
     */
    var actions: [AdAction] {
        get {
            return [.load, .show]
        }
    }
    
    /**
     Retrieves the display status for the event.
     - Parameter event: Status event.
     - Returns: A tuple containing the status display title, optional message, and highlighted state.
     */
    func status(for event: AdEvent) -> (title: String, message: String?, isHighlighted: Bool) {
        let message = messages[event]
        let isHighlighted = (eventTriggered[event] ?? false)
        return (title: title[event] ?? "", message: message, isHighlighted: isHighlighted)
    }
    
    /**
     Sets the status for the event to highlighted. If the status is already highlighted,
     nothing is done.
     - Parameter event: Status event.
     - Parameter message: optional string containing status message.
     - Parameter complete: Completion closure.
     */
    func setStatus(for event: AdEvent, message: String? = nil, complete:(() -> Swift.Void)) {
        eventTriggered[event] = true
        messages[event] = message
        complete()
    }
    
    /**
     Clears the highlighted state for all status events.
     - Parameter complete: Completion closure.
     */
    func clearStatus(complete:(() -> Swift.Void)) {
        eventTriggered = [:]
        messages = [:]
        complete()
    }
}
