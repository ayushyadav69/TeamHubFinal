//
//  BackgroundSyncManager.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation
import BackgroundTasks

final class BackgroundSyncManager {

    static let shared = BackgroundSyncManager()

    private let taskIdentifier = "com.teamhub.processing"

    private init() {}

    // MARK: Register

    func register(repository: EmployeeRepository) {

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in

            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }

            self.handleProcessing(task: processingTask, repository: repository)
        }
    }

    // MARK: Schedule

    func schedule() {

        let request = BGProcessingTaskRequest(identifier: taskIdentifier)

        // System will wait for good conditions → improves reliability massively
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false

        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background processing scheduled")
        } catch {
            print("❌ Failed to schedule processing:", error)
        }
    }

    // MARK: Handle Task

    private func handleProcessing(
        task: BGProcessingTask,
        repository: EmployeeRepository
    ) {

        // always reschedule next run
        schedule()

        let work = Task(priority: .background) {
            try await repository.fetchAndSync(force: false)
        }

        task.expirationHandler = {
            work.cancel()
        }

        Task {
            do {
                try await work.value
                task.setTaskCompleted(success: !work.isCancelled)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
}
