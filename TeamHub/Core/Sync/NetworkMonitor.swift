//
//  NetworkMonitor.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation
import Network
import Observation

@MainActor
@Observable
final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected: Bool = false
    private(set) var isExpensive: Bool = false

    private init() {}

    func start() {

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            Task { @MainActor in
                self.isConnected = path.status == .satisfied
                self.isExpensive = path.isExpensive
            }
        }

        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
