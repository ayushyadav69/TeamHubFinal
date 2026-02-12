//
//  SyncPolicy.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation

protocol SyncPolicy {
    func shouldSync() -> Bool
    func markSynced()
}
