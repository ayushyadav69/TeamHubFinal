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

    private let taskIdentifier = "com.teamhub.refresh"

    private init() {}

    // MARK: - Register

    func register(repository: EmployeeRepository) {

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in

            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }

            self.handleAppRefresh(task: refreshTask, repository: repository)
        }
    }

    // MARK: - Schedule

    func schedule() {

        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Failed to schedule background refresh:", error)
        }
    }

    // MARK: - Handle Task

    private func handleAppRefresh(
        task: BGAppRefreshTask,
        repository: EmployeeRepository
    ) {

        // Always reschedule next execution
        schedule()

        let refreshTask = Task {

            do {
                // Repository is @MainActor → safe
                try await repository.fetchAndSync(force: false)
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }
    }
}
