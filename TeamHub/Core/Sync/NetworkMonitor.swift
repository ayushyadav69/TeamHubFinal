//
//  NetworkMonitor.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private var continuation: AsyncStream<Bool>.Continuation?

    private(set) var isConnected: Bool = true   // snapshot

    lazy var connectionStream: AsyncStream<Bool> = {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(self.isConnected) // immediate value
        }
    }()

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let connected = path.status == .satisfied

            Task { @MainActor in
                self.isConnected = connected
                self.continuation?.yield(connected)
            }
        }

        monitor.start(queue: queue)
    }
}
