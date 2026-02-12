//
//  DefaultSyncPolicy.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation

final class DefaultSyncPolicy: SyncPolicy {

    private let userDefaults: UserDefaults
    private let expiryInterval: TimeInterval
    private let lastSyncKey = "employee_last_sync"

    init(
        userDefaults: UserDefaults = .standard,
        expiryInterval: TimeInterval = 60 * 60 // 1 hour
    ) {
        self.userDefaults = userDefaults
        self.expiryInterval = expiryInterval
    }

    func shouldSync() -> Bool {

        guard let lastSync = userDefaults.object(forKey: lastSyncKey) as? Date else {
            return true // First launch
        }

        return Date().timeIntervalSince(lastSync) > expiryInterval
    }

    func markSynced() {
        userDefaults.set(Date(), forKey: lastSyncKey)
    }
}
