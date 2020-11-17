//
//  TypedNotification.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

protocol TypedNotification {
    /**
     Name of the notification.
     */
    static var name: Notification.Name { get }
    
    /**
     An optional object that acts as the one posting the notification.
     */
    var postingObject: Any? { get }
    
    /**
     The target notification center.
     */
    var notificationCenter: NotificationCenter { get }
}

// MARK: - Default `TypedNotification` implementation

extension TypedNotification {
    /**
     This is the key for accessing the `TypedNotification` stored in `Notification.userInfo`.
     */
    private static var userInfoKey: String {
        return "TypedNotification"
    }
    
    /**
     Default value: nil
     */
    var postingObject: Any? {
        return nil
    }
    
    /**
     Default value: `.default`
     */
    var notificationCenter: NotificationCenter {
        return .default
    }
    
    /**
     Post the notification.
     */
    func post() {
        notificationCenter.post(name: Self.name, object: postingObject, userInfo: [Self.userInfoKey: self])
    }
    
    /**
     Add an observer for the notification.
     
     Note 1: The default handling queue is `OperationQueue.main`.
     
     Note 2: The returned `Notification.Token` has to be retained to keep the observation active. If
     the returned token is deallocated, the observer is removed from notification center as well.
     
     - Parameter notificationCenter: targeted `NotificationCenter`, default to `.default`
     - Parameter postingObject: an `Any?` object that acts as the one posting the notification
     - Parameter queue: the `OperationQueue` that invokes the handler
     - Parameter handler: a notification handler that provides the posted `TypedNotification`
     - Returns: a `Notification.Token` that strongly refer to the observer
     */
    static func addObserver(notificationCenter: NotificationCenter = .default,
                            postingObject: Any? = nil,
                            queue: OperationQueue? = .main,
                            handler: @escaping (Self) -> Void) -> Notification.Token {
        let rawToken = notificationCenter.addObserver(forName: name, object: postingObject, queue: queue) { notification in
            guard let userInfo = notification.userInfo, let typedNotification = userInfo[userInfoKey] as? Self else {
                assertionFailure("\(#function) unable to obtain a `TypedNotification` from `userInfo`")
                return
            }
            handler(typedNotification)
        }
        return Notification.Token(rawToken: rawToken, notificationCenter: notificationCenter)
    }
}
