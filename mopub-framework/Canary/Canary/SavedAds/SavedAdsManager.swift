//
//  SavedAdsManager.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

final class SavedAdsManager {
    /**
     Notify when `savedAds` is changed.
     */
    struct DataUpdatedNotification: TypedNotification {
        static let name = Notification.Name(rawValue: String(describing: DataUpdatedNotification.self))
    }

    /**
     Use a singleton to represent the global resource stored in `UserDefaults.standard`.
     */
    static let sharedInstance = SavedAdsManager()

    /**
     An sorted array `AdUnit` with the most recently saved ad comes first.
     */
    private(set) var savedAds: [AdUnit]
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        savedAds = userDefaults.persistentAdUnits
    }

    /**
     Add the ad unit and remove duplicate if there is any.
     Note: A `DataUpdatedNotification` is posted before returning.
     */
    func addSavedAd(adUnit: AdUnit) {
        savedAds.removeAll(where: { adUnit.id == $0.id }) // avoid duplicate
        savedAds.insert(adUnit, at: 0) // latest first
        userDefaults.persistentAdUnits = savedAds
        DataUpdatedNotification().post()
    }
    
    /**
     Remove the provided ad unti from persistent storage.
     Note: A `DataUpdatedNotification` is posted before returning.
     */
    func removeSavedAd(adUnit: AdUnit) {
        savedAds.removeAll(where: { adUnit.id == $0.id })
        DataUpdatedNotification().post()
    }
}

// MARK: - Persistent storage with `UserDefaults`

private extension UserDefaults {
    /**
     The private `UserDefaults.Key` for accessing `persistentAdUnits`.
     */
    private var adUnitDataKey: Key<Data?> {
        return Key<Data?>("AdUnitData", defaultValue: nil)
    }
    
    var persistentAdUnits: [AdUnit] {
        get {
            do {
                guard let data = self[adUnitDataKey] else {
                    return []
                }
                return try JSONDecoder().decode([AdUnit].self, from: data)
            } catch {
                print("\(#function) caught error: \(error)")
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                self[adUnitDataKey] = data
            } catch {
                print("\(#function) caught error: \(error)")
            }
        }
    }
}
