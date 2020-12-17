//
//  Notification+Token.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

extension Notification {
    /**
     This `Token` class is a wrapper of `rawToken: NSObjectProtocol`, which is the returned value of
     `NotificationCenter.addObserver(forName:object:queue:using) -> NSObjectProtocol`. When this
     `Token` is deallocated, it automatically removes the original observer from notification center.
     To take advantage of the automatic observer removal feature of this `Token`, keep a strong
     reference to this `Token` in an instance variable of the observer (in a collection or not),
     so that this `Token` is deallocated together with the observer, and consequently triggers
     `NotificationCenter.removeObserver`.
     */
    final class Token {
        /**
         An opaque object to act as the observer, returned by `NotificationCenter.addObserver(forName
         name:object:queue:using)`.
         */
        let rawToken: NSObjectProtocol
        
        /**
         The targeted notification center.
         */
        let notificationCenter: NotificationCenter
        
        init(rawToken: NSObjectProtocol, notificationCenter: NotificationCenter) {
            self.rawToken = rawToken
            self.notificationCenter = notificationCenter
        }
        
        deinit {
            notificationCenter.removeObserver(rawToken)
        }
    }
}
